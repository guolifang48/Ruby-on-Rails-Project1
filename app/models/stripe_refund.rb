class StripeRefund < ActiveRecord::Base
  belongs_to :stripe_charge

  def amount_in_dollars
    "%.2f" % (self.amount.to_f / 100)
  end

end
