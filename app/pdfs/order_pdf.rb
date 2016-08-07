class OrderPdf < Prawn::Document
  include CardsHelper
  include OrdersHelper

  def initialize(order, view)
    super(top_margin: 40)
    @order = order
    order_number
    order_status
    user_info
    shipping_info
    line_items
    card_charges
  end

  def order_number
    text "Order \##{@order.order_no}", size: 13, style: :bold
  end

  def order_status
    text "current status: #{@order.status} - #{@order.receipt_status}"
  end

  def user_info
    move_down 10
    if @order.user.present?
      text "User: #{@order.user.full_name}\nEmail: #{@order.user.email}", size: 10, style: :normal
    else
      text "User was deleted", size: 10, style: :bold, color: 'a94442'
    end
  end

  def shipping_info
    if !@order.shipping_info_present?
      return
    end
    move_down 10
    data = ''
    data += "#{@order.ship_to_name}"
    data += "#{@order.phone}"
    data += "\n#{@order.street_address_first_line}"
    if @order.street_address_second_line.present?
      data += "\n#{@order.street_address_second_line}"
    end
    data += "\n#{@order.city}, #{@order.province} #{@order.zipcode}"
    text data, size: 10, style: :normal
  end

  def line_items
    move_down 20
    table (line_item_rows + subtotal_rows) do
      # Global table styles
      self.row_colors = ["d9edf7", "ffffff"]
      self.header = true
      row(0).font_style = :bold
      columns(1..3).align = :center
      style(columns(0..3), padding:[7, 13, 7, 13], borders:[], size:10)
      style(columns(0), padding:[7, 13, 7, 5], borders:[], size:10, align: :left)
      style(columns(-1), align: :left, padding:[7, 13, 7, 5])

      # Subtotal row styles
      style(row(-4..-1), font_style: :normal, color:"31708f", background_color:'ffffff', padding:[3, 13, 3, 5])
      style(row(-1), font_style: :bold, color:"3c763d")

    end
  end

  def line_item_rows
    [["Card", "Rarity", "Card price", "Full price"]] +
    @order.order_cards.map do |order_card|
      ["#{order_card.quantity}x #{order_card.card.name}", (abbreviate_rarity order_card.card), "$#{order_card.current_price_in_dollars}", "$#{order_card.card_total_in_dollars}"]
    end
  end

  def subtotal_rows
    row_array = []
    row_array << ["Cards subtotal", "", "", "$#{@order.subtotal_in_dollars}"]
    row_array << ["Shipping","", "", "$#{value_in_dollars Order::SHIPPING[@order.shipping_method]['price']}"]
    row_array << ["Rental period", "", "","$#{@order.duration_cost_in_dollars}"]

    if @order.coupon.present?
      row_array << ["Coupon ##{@order.coupon.coupon_code}", "", "","#{@order.coupon.coupon_value}% off"]
    end

    if @order.get_sales_tax > 0
      row_array << ["Sales tax (#{@order.sales_tax_to_s})", "", "","$#{@order.sales_tax_in_dollars}"]
    end

    row_array << ["Total","", "","$#{@order.order_total_in_dollars}"]

    return row_array
  end

  # => #<StripeCharge id: 4, order_id: 39, charge_id: "ch_154dJKHhcB6YPqw2K121gA5n", amount: 2560, last_4_digits: "4242", card_type: "Visa", exp_month: "12", exp_year: "2017", admin_memo: "", invoice_memo: "", charge_type: "order_fees", created_at: "2014-11-30 19:26:00", updated_at: "2014-11-30 19:26:00">

  def card_charges
    if @order.stripe_charges.blank?
      return
    end
    move_down 30
    text "Charges", size: 11, style: :bold
    @order.stripe_charges.each do |c|
      move_down 5
      text "#{format_date c.charge_date} -- #{c.card_type} ending in #{c.last_4_digits} exp #{c.exp_month}/#{c.exp_year} -- $#{c.amount_in_dollars}", size: 10, style: :normal
    end

  end

end
