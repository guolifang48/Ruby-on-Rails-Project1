class Admin::StripeChargesController < ApplicationController
  before_action :set_stripe_charge, only: [:show, :edit, :update, :destroy]

  def new
    @order = Order.find(params[:order_id])
    @stripe_charge = @order.stripe_charges.build
    respond_to do |format|
      format.js {}
    end
  end

  def create
    @order = Order.find(params[:order_id])
    @stripe_charge = @order.stripe_charges.build(stripe_charge_params)
    @stripe_charge.save_and_charge!
    OrdersMailer.card_charged(@order, @stripe_charge).deliver
    if params[:order_paid]
      @order.paid = true
      @order.save
    end
    respond_to do |format|
      format.js {}
    end
  end

  def refund
    @stripe_charge = StripeCharge.find(params[:id])
    @order = @stripe_charge.order
    refunds = @stripe_charge.stripe_refunds.count
    @stripe_charge.refund

    respond_to do |format|
      format.js {}
    end
  end

  private

    def stripe_charge_params
      params.require(:stripe_charge).permit(:amount_in_dollars, :amount, :admin_memo, :invoice_memo, :order_paid, :charge_type)
    end
end
