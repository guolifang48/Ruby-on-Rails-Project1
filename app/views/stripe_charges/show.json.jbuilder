json.extract! @stripe_charge, :id, :order_id, :charge_id, :amount, :last_4_digits, :card_type, :exp_month, :exp_year, :created_at, :updated_at
