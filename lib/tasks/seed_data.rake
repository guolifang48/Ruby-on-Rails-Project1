

task :seed_data => :environment do

  # Make 15 users

  15.times do
    first_name = Faker::Name.first_name
    last_name = Faker::Name.first_name
    email = Faker::Internet.email(first_name)
    time_zone = 'Eastern Time (US & Canada)'
    password = 'testing'

    u = User.new(first_name:first_name, last_name:last_name, email:email, password:password, password_confirmation:password, time_zone:time_zone)
    u.save
  end

  # For the first user, create an order
  4.times do |i|
  u_id = i + 10
  u = User.find(u_id)
  order = u.orders.build
  order.save
  card_set = CardSet.find_by(code:'BNG')
  upper_range = card_set.cards.count
  cards_hash = card_set.cards.each_with_index {|card, index| { index:"#{card.id}" }}

  20.times do
    card_index = rand(1..upper_range)
    card = cards_hash[card_index]

    if card.present?
      qty = rand(1..4)
      price = card.raw_price
      id = card.id
      order.order_cards.create(card_id:id, current_price:price, quantity:qty)

      cards_hash.delete_at(card_index)
    end
  end

  # At this point the user has 20 cards in their cart.

  number = '4242424242424242'
  exp_month = '02'
  exp_year = '2017'
  cvc = '123'

  customer = Stripe::Customer.create(
    :description => "Customer for #{u.email}",
    :card => {
      :number => number,
      :exp_month => exp_month,
      :exp_year => exp_year,
      :cvc => cvc
    }
  )

  last_4_digits = customer["cards"]["data"][0]["last4"]
  card_type = customer["cards"]["data"][0]["brand"]
  u.update_columns(stripe_customer_id:customer.id, last_4_digits:last_4_digits, card_type:card_type)

  order.date_needed = Time.zone.now + 4.days
  order.shipping_method = 'First Class'
  order.days_needed = 14
  order.ship_to_name = "#{u.first_name} #{u.last_name}"
  order.street_address_first_line = Faker::Address.street_address
  order.city = Faker::Address.city
  order.province = Faker::Address.state_abbr
  order.zipcode = Faker::Address.zip
  order.country = 'US'
  order.save
  order.authorize_amount
  order.set_date_due_back

  end
end