class Order < ActiveRecord::Base
  has_many :order_cards, -> { order(:id) }, dependent: :destroy
  has_many :stripe_charges
  has_many :order_notes
  has_many :cards, through: :order_cards

  belongs_to :user
  belongs_to :coupon

  before_create :store_current_indiana_sales_tax
  before_create :create_return_token

  validates :return_token, uniqueness: true

  default_scope { order('orders.created_at desc') }

  scope :open, -> { where("orders.authorized IS NOT NULL AND orders.returned IS NULL AND orders.canceled IS NULL") }

  scope :authorized_not_yet_shipped, -> { where("orders.authorized IS NOT NULL AND orders.shipped IS NULL AND orders.returned IS NULL AND orders.canceled IS NULL")
  }

  scope :closed, -> { where("orders.returned IS NOT NULL") }

  scope :canceled, -> { where("orders.canceled IS NOT NULL") }

  # These are decks that are shipped but not returned and it is the day they are due back.
  scope :due_back, -> { where("orders.shipped IS NOT NULL AND orders.returned IS NULL AND orders.canceled IS NULL").where("orders.date_due_back < (?)", Time.zone.now) }

  # Current sales tax applied to IN residents. Also stored on orders
  # The logic is that it is set on order create but only applied if IN
  SALES_TAX_IN = '0.07'

  SHIPPING = { 'First Class' => { 'price' => 850, 's' => 'USPS First Class Parcel (2 - 4 Days)'}, 'Priority Mail' => { 'price' => 2000, 's' => 'USPS Priority Mail Express (1 - 2 days)' }, 'Free shipping' => { 'price' => 0, 's' => 'Local Pickup'} }

  def self.sales_tax_to_s
    value = "%.1f" % (SALES_TAX_IN.to_f * 100)
    "#{value}%"
  end

  def sales_tax_to_s
    value = "%.1f" % (sales_tax_in.to_f * 100)
    "#{value}%"
  end

  def self.last_cart
    where("orders.authorized IS NULL").order("created_at DESC").first
  end

  def cancel_order(origin)
    update_columns(canceled:origin)
    order_notes.create!(subject: "#{origin} canceled order")
  end

  def canceled_by_admin?
    (canceled == 'Admin') ? true : false
  end

  def store_current_indiana_sales_tax
    self.sales_tax_in = SALES_TAX_IN.to_f
  end

  def set_order_number
    order_no = "#{created_at.strftime('%M%d%y')}-#{id}"
    update_columns(order_no:order_no)
  end

  def was_canceled?
    (canceled.is_a? String) ? true : false
  end

  def sales_tax_in_dollars
    value_in_dollars(get_sales_tax)
  end

  def shipping_method_to_s
    SHIPPING[shipping_method]['s']
  end

  def shipping_method_price_in_dollars
    value_in_dollars(SHIPPING[shipping_method]['price'])
  end

  def due_back?
    true if Time.zone.now > date_due
  end

  def set_date_due_back
    date_due = date_needed + (days_needed).try('days')
    update_columns(date_due:date_due)
  end

  def total_cards
    order_cards.sum(:quantity)
  end

  def subtotal
    order_cards.map do |c| c.card_total end.sum
  end

  def subtotal_in_dollars
    "%.2f" % (self.subtotal.to_f / 100)
  end

  def subtotal_sum_in_dollars
    "%.2f" % ((self.subtotal + (self.duration_cost || 0)).to_f / 100)
  end

  def deck_due_back_soon
  end

  def authorize_amount
    charge = Stripe::Charge.create(
      :amount => order_total,
      :currency => 'usd',
      :customer => user.stripe_customer_id,
      :description => "Authorizing card for SpareDeck order",
      :capture => false
    )

    if charge
      update_columns(authorized:Time.zone.now)
    end

    rescue Stripe::CardError => e
      errors.add :base, e.json_body[:error][:message]
      return false
  end

  # Pricing calculation for deliver
  # Pricing Calculation: 3 days = Original cart price.
  # Each day after 3 days up to 7 days = Cart price + $1 per day
  # Each day after 7 days up to 30 days = Cart price + $7 + $0.50 per day

  def duration_cost(days = days_needed)
    days = 0 if days.nil?
    if days == 3
      cost = 0
    elsif days > 3 && days <= 7
      cost = 100 * days
    elsif(days > 7)
      cost = 700 + (50 * days)
    end
  end

  def duration_cost_in_dollars(days = days_needed)
    cents = duration_cost(days)
    value_in_dollars(cents)
  end

  def get_sales_tax
    if province == 'IN' || pickup
      cost =
      subtotal +
      duration_cost(days_needed) +
      SHIPPING[shipping_method]['price']
      sales_tax = (cost * SALES_TAX_IN.to_f).round.to_i
    else
      0
    end
  end

  def order_total
    subtotal +
    duration_cost(days_needed) +
    SHIPPING[shipping_method]['price']  +
    get_sales_tax -
    coupon_discount
  end

  def coupon_discount
    c = coupon

    return 0 if c.blank?

    case c.coupon_type
    when 'percentage'
      ((duration_cost(days_needed).to_f + subtotal.to_f) * (c.coupon_value.to_f/100 )).round.to_i
    end
  end

  # The status method is for display to users. From their point of view
  # an order may be placed, shipped, due back, returned or canceled.
  def status
    if canceled.present?
      return 'canceled'
    elsif returned.present?
      return 'returned'
    elsif due_back?
      return 'due back'
    elsif shipped.present?
      return 'shipped'
    elsif authorized
      return 'placed'
    else
      return 'placed'
    end
  end

  def receipt_status
    if canceled.present?
      return 'canceled'
    elsif returned.present?
      return 'paid'
    elsif due_back?
      return 'paid'
    elsif shipped.present?
      return 'paid'
    elsif authorized
      return 'placed'
    else
      return 'placed'
    end
  end

  def order_total_in_dollars
    value_in_dollars(order_total)
  end

  def value_in_dollars(value)
    "%.2f" % (value.to_f / 100)
  end

  def release_cards
  end

  def check_availability
    order_cards.each do |order_card|
      card = order_card.card
      available = card.available_for(date_needed, date_due, order_card.quantity)
      order_card.update_columns(available:available)
    end
  end

  def cleanup_unused_carts

  end

  def has_unavailables?
    true if (order_cards.collect{ |o| o.available }.include? false)
  end

  def shipping_info_present?
    true if street_address_first_line.present? && city.present? && province.present?
  end

  def create_return_token
    begin
      self.return_token = SecureRandom.urlsafe_base64
    end while Order.exists?(return_token: self.return_token)
  end
end

