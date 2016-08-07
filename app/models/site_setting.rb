class SiteSetting < ActiveRecord::Base

  def price_in_dollars
    "%.2f" % (self.value.to_f / 100)
  end

  def price_in_dollars=(val)
    self.value = (val.gsub(/,/, '').to_f * 100).to_s
  end

  def price
    self.value.to_f
  end

end
