class OrdersController < ApplicationController
  include CardsHelper

  def show
    @order = current_user.orders.find(params[:id])
    @order_cards_hash = parse_reference_deck_by_type(@order.order_cards)
  end

  def index
    @orders = current_user.orders.all
  end

  def cancel
    @order = current_user.orders.find(params[:id])

    if @order.shipped.nil?
      @order.cancel_order('User')
    else
      flash[:error] = 'Your order has already shipped and cannot be canceled. To proceed please contact an admin at help@sparedeck.com'
    end

    respond_to do |format|
      format.html { redirect_to account_url }
    end
  end

  def cart
    # Is there a custom time theyre checking the cards out for?
    @custom = ([nil, 3, 14, 30].include? @cart.days_needed) ? false : true
    @time_now = Time.zone.now
    @min_date = 2.business_days.from_now.in_time_zone('Eastern Time (US & Canada)')

    if @cart.date_needed.present? && (@cart.date_needed >= 2.business_days.from_now.in_time_zone('Eastern Time (US & Canada)'))
      @display_date = @cart.date_needed
    else
      @display_date = 3.business_days.from_now.in_time_zone('Eastern Time (US & Canada)')
    end

    @order_cards_hash = parse_reference_deck_by_type(@cart.order_cards.includes(:card))
  end

  def user_return
    @order = Order.find_by(return_token:params[:return_token])

    @order.update_columns(user_return_confirmation:Time.zone.now) if @order

    respond_to do |format|
      format.html {}
    end
  end

  def process_schedule
    @cart.update_attributes(order_params)
    @cart.save

    @cart.set_date_due_back
    @cart.check_availability

    respond_to do |format|
      format.html {
        if (@cart.has_unavailables?)
          redirect_to cart_url
        else

          if @cart.order_no.blank?
            @cart.set_order_number
          end

          redirect_to payment_order_path(@cart)
        end
      }
    end

    # If cards are available for that date, the order is committed - unauthorized, to prevent other users from checking out cards.
  end

  def payment
    @order = current_user.orders.find(params[:id])
    @order_cards_hash = parse_reference_deck_by_type(@order.order_cards)
    if current_user.guest
      @invitation = Invitation.new
    end
  end

  def authorize_payment
    @order = current_user.orders.find(params[:id])
    @order.update_attributes(order_params)
    current_user.update_customer(params[:stripe_card_token])
    @order.authorize_amount

    if @order.errors.any?
      flash[:error] = @order.errors.full_messages.first
      redirect_to payment_order_path(@order)
    else
      OrdersMailer.order_received(@order).deliver
      OrdersMailer.new_order(@order).deliver
      flash[:success] = 'Order received. You will be notified by email when your card is charged and when your deck ships!'

      respond_to do |format|
        format.html {
          if current_user.primary_verification_quiz.present? || (current_user.has_role? :admin)
            redirect_to account_url
          else
            redirect_to new_user_verification_quiz_path(current_user)
          end
        }
      end
    end

  end

  def edit
  end

  def coupon_code
    @order = current_user.orders.find(params[:id])
    @coupon = Coupon.active.find_by(coupon_code:params[:coupon_code])
    if @coupon.present?
      @cart.coupon_id = @coupon.id
      @cart.save
    end

    respond_to do |format|
      format.js {}
    end
  end

  def receipt
    @order = current_user.orders.find(params[:id])
    respond_to do |format|

      format.pdf do
        pdf = OrderPdf.new(@order, view_context)
        send_data pdf.render, filename: "order_#{@order.order_no}", type: "application/pdf", disposition: "inline"
      end
    end
  end

  def clear_cart
    @cart.order_cards.destroy_all
    respond_to do |format|
      format.html { redirect_to cart_url }
    end
  end

  private

    def order_params
      params.require(:order).permit(:date_needed, :shipped, :returned, :amount, :days_needed, :date_due, :comment, :shipping_method, :ship_to_name, :stripe_card_token, :street_address_first_line, :street_address_second_line, :city, :province, :zipcode, :country, :billing_street_address_first_line, :billing_street_address_second_line, :billing_city, :billing_province, :billing_ship_to_name, :billing_zipcode, :billing_country, :billing_phone, :phone)
    end
end


