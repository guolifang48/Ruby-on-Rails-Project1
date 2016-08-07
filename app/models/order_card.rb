class OrderCard < ActiveRecord::Base
  belongs_to :card
  belongs_to :order

  scope :upcoming_reserved, lambda { |date|
    joins(:order).where("date_needed + (days_needed * interval '1 day') + (orders.order_delayed * interval '1 day') > (?)", date).where("orders.authorized IS NOT NULL AND orders.canceled IS NULL")
  }

  scope :active, lambda { |date|
     (joins(:order).where("date_needed < (?) AND ((date_needed + days_needed * interval '1 day') + (orders.order_delayed * interval '1 day')) > (?)", date, (date + 3.days) ).where("orders.authorized IS NOT NULL AND orders.canceled IS NULL"))
  }

  def card_total
    quantity * current_price
  end

  def card_total_in_dollars
    "%.2f" % (self.card_total.to_f / 100)
  end

  def current_price_in_dollars
    "%.2f" % (self.current_price.to_f / 100)
  end

  def card_set
    Card.find(card_id).card_set
  end

end
