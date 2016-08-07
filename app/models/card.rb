class Card < ActiveRecord::Base
  belongs_to :card_set
  has_many :order_cards

  validate :inventory_not_less_than_amount_currently_out
  validates_numericality_of :inventory, greater_than_or_equal_to: 0

  scope :with_inventory, ->  {
    select("cards.*").where("cards.inventory > 0").order("cards.name asc")
  }

  scope :not_in_cart, lambda { |cart|
    where("cards.id NOT IN (?)", cart.card_ids)
  }

  scope :search_by_name, lambda { |q|
    (q ? joins(:card_set).where(["lower(cards.name) LIKE ?", '%'+ q + '%' ]).order("card_sets.release_date desc")  : {})
  }

  def inventory_not_less_than_amount_currently_out
    cards_out = order_cards.active(Time.zone.now).sum(:quantity)

    if cards_out > inventory
      errors.add(:inventory, "can't be less than number of cards currently out")
    end
  end

  def get_price
    price.present? ? price_in_dollars : price_by_rarity.try(:price_in_dollars)
  end

  def raw_price
    price.present? ? price : price_by_rarity.price
  end

  def price_by_rarity
    case rarity
    when "Common"
      SiteSetting.find_by(name:'price-by-rarity-c')
    when "Uncommon"
      SiteSetting.find_by(name:'price-by-rarity-uc')
    when "Rare"
      SiteSetting.find_by(name:'price-by-rarity-r')
    when "Mythic Rare"
      SiteSetting.find_by(name:'price-by-rarity-mr')
    when "Basic Land"
      SiteSetting.find_by(name:'price-by-rarity-bl')
    end
  end

  def price_in_dollars
    "%.2f" % (self.price.to_f / 100)
  end

  def price_in_dollars=(val)
    self.price = val.gsub(/,/, '').to_f * 100
  end

  # Reserved is the quantity of inventory *currently* out
  # All of this card's order_cards that are active
  def reserved(date = Time.zone.now)
    order_cards.active(date).sum(:quantity)
  end

  def upcoming_reserved
    order_cards.upcoming_reserved(Time.zone.now).sum(:quantity)
  end

  def available(date = Time.zone.now)
    return inventory if inventory.zero?
    inventory - reserved(date)
  end

  # Used to determine if the card is availabel for a given
  # order period and at the needed quantity.
  def available_for(start_date, end_date, qty)
    # one approach, for each day in the period test available quantity
    start_date = start_date.to_datetime.beginning_of_day
    end_date = end_date + 3.days
    end_date = end_date.to_datetime.end_of_day

    (start_date..end_date).each do |d|
      return false if available(d) < qty
    end

    true
  end

  # Calculates when the requested inventory is next available for the
  # period requested.
  def next_available_date(date_needed, days_needed, qty)
    lower_date = date_needed.to_datetime.beginning_of_day
    upper_date = lower_date + 60.days
    upper_date = upper_date.to_datetime.end_of_day

    (lower_date..upper_date).each do |d|
      if available(d) >= qty
        end_date = d + days_needed.days
        is_available = available_for(d, end_date, qty)

        if is_available
          return d
        end

      end
    end

    return false
  end

end
