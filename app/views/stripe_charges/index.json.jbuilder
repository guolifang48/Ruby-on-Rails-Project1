json.array!(@stripe_charges) do |stripe_charge|
  json.extract! stripe_charge, :id, :order_id, :charge_id, :amount, :last_4_digits, :card_type, :exp_month, :exp_year
  json.url stripe_charge_url(stripe_charge, format: :json)
end
