class StripeCharge < ActiveRecord::Base
  belongs_to :order
  has_many :stripe_refunds

  def user
    order.user
  end

  def save_and_charge!
    charge = Stripe::Charge.create(
      :amount => amount,
      :currency => 'usd',
      :customer => user.stripe_customer_id,
      :description => invoice_memo,
      :capture => true
    )

    if charge
      self.charge_id = charge.id
      self.last_4_digits = charge.card.last4
      self.exp_month = charge.card.exp_month
      self.exp_year = charge.card.exp_year
      self.card_type = charge.card.brand
      self.charge_date = Time.at(charge.created).to_datetime
      save!
    end

    rescue Stripe::CardError => e
      errors.add :base, e.json_body[:error][:message]
      return false
  end

  def card_charged
    "#{card_type} ending in #{last_4_digits}"
  end

  def refund(refund_amount = amount)
    ch = Stripe::Charge.retrieve(charge_id)
    refund = ch.refunds.create

    if refund
      create_stripe_refund(refund)
    end

    rescue Stripe::StripeError => e
      errors.add :base, e.json_body[:error][:message]
      return false
  end

  def create_stripe_refund(refund)
    stripe_refunds.create!(
     stripe_charge_id:id, refund_id:refund.id, amount:refund.amount
     )
  end

  def total_refunded?
    refunded = stripe_refunds.sum(:amount)
    if refunded == amount
      return true
    else
      return false
    end
  end

  def amount_in_dollars
    "%.2f" % (self.amount.to_f / 100)
  end

  def amount_in_dollars=(val)
    self.amount = val.gsub(/,/, '').to_f * 100
  end


end
