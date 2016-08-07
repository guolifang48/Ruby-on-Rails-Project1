class Admin::OrdersController < ApplicationController
  include CardsHelper
  before_action :authorize_admin
  before_action :set_order, only: [:show, :shipped_form, :shipped, :charge, :edit, :update, :returned, :receipt]

  def index
    case params[:status]
    when 'open'
      @orders = Order.open
    when 'closed'
      @orders = Order.closed
    when 'canceled'
      @orders = Order.canceled
    end

    @orders = @orders.paginate(page:params[:page], per_page:50)

  end

  def show
    @order = Order.find(params[:id])
    @order_cards_hash = parse_reference_deck_by_type(@order.order_cards)
    @card_type_array = card_type_array
  end

  def edit
    respond_to do |format|
      format.js {}
    end
  end

  def update
    @order.update(order_params)
    respond_to do |format|
      format.js {}
    end
  end

  def shipped_form
    respond_to do |format|
      format.js {}
    end
  end

  def cancel
    @order = Order.find(params[:id])

    if @order.shipped.nil?
      @order.cancel_order('Admin')
    else
      flash[:error] = 'The order has already shipped and cannot be canceled.'
    end

    respond_to do |format|
      format.html { redirect_to admin_order_path(@order) }
    end
  end

  def shipped
    @order.update(order_params)
    OrdersMailer.shipped(@order).deliver
  end

  def returned
    @order.returned = Time.zone.now
    @order.save
    @order.release_cards
    OrdersMailer.returned(@order).deliver
  end

  def receipt
    respond_to do |format|

      format.pdf do
        pdf = OrderPdf.new(@order, view_context)
        send_data pdf.render, filename: "order_#{@order.order_no}", type: "application/pdf", disposition: "inline"
      end
    end
  end

  def form_partial
    respond_to do |format|
      format.js {}
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:date_needed, :days_needed, :date_due, :comment, :shipping_method, :street_address_first_line, :street_address_second_line, :city, :province, :zipcode, :country, :ship_to_name, :paid, :pulled, :shipped, :returned, :shipping_message, :shipping_reference_no, :sales_tax, :order_delayed, :billing_street_address_first_line, :billing_street_address_second_line, :billing_city, :billing_province, :billing_ship_to_name, :billing_zipcode, :billing_country, :billing_phone, :phone)
  end

end

