class Coupon < ActiveRecord::Base

  scope :active, -> { where("coupons.start_date < (?) AND coupons.end_date > (?)", Time.zone.now, Time.zone.now) }

end
