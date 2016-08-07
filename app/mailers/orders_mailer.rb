class OrdersMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  include CardsHelper
  include OrdersHelper
  helper :cards
  helper :orders

  layout 'email_layout'
  default from: "SpareDeck<help@sparedeck.com>"

  # New order is to notify the admin
  def new_order(order)
    @order = order
    @user = @order.user
    @order_cards_hash = parse_reference_deck_by_type(@order.order_cards)
    @card_type_array = card_type_array
    mail to: "#{ENV['ADMIN_EMAIL']}", subject: "New Order!"
  end

  def order_received(order)
    @order = order
    @user = @order.user
    @order_cards_hash = parse_reference_deck_by_type(@order.order_cards)
    @card_type_array = card_type_array
    mail to: @user.email, subject: "Order ##{@order.order_no} Received"
  end

  def card_charged(order, stripe_charge)
    @stripe_charge = stripe_charge
    @order = order
    @user = @order.user
    @order_cards_hash = parse_reference_deck_by_type(@order.order_cards)
    @card_type_array = card_type_array
    mail to: @order.user.email, subject: "Credit Card Payment"
  end

  # card_charged

  def shipped(order)
    @order = order
    @user = @order.user
    @order_cards_hash = parse_reference_deck_by_type(@order.order_cards)
    @card_type_array = card_type_array
    mail to: @order.user.email, subject: "Order ##{@order.order_no} Shipped"
  end

  def deck_due_back_soon(order)
    @order = order
    @user = @order.user
    @order_cards_hash = parse_reference_deck_by_type(@order.order_cards)
    @card_type_array = card_type_array
    mail to: @order.user.email, subject: "Reminder - Cards Due Soon"
  end

  def deck_due_back(order)
    @order = order
    @user = @order.user
    @order_cards_hash = parse_reference_deck_by_type(@order.order_cards)
    @card_type_array = card_type_array
    mail to: @order.user.email, subject: "Cards Due In Mail Today"
  end

  def returned(order)
    @order = order
    @user = @order.user
    mail to: @order.user.email, subject: "Cards Received"
  end

  # deck_received

end
