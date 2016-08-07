class Admin::CouponsController < ApplicationController
  before_action :authorize_admin
  before_action :set_coupon, only: [:show, :edit, :update, :destroy]

  def index
    @coupons = Coupon.all
  end

  def new
    @coupon = Coupon.new
    respond_to do |format|
      format.js { render 'admin/coupons/launch_form' }
    end
  end

  def edit
    respond_to do |format|
      format.js { render 'admin/coupons/launch_form' }
    end
  end

  def create
    @coupon = Coupon.new(coupon_params)
    @coupon.save
    @coupons = Coupon.all
    respond_to do |format|
      format.js { render 'admin/coupons/render_table' }
    end
  end

  def update
    @coupon.update(coupon_params)
    @coupons = Coupon.all
    respond_to do |format|
      format.js { render 'admin/coupons/render_table' }
    end
  end

  def destroy
    @coupon.destroy
    @coupons = Coupon.all
    respond_to do |format|
      format.js { render 'admin/coupons/render_table' }
    end
  end

  private
    def set_coupon
      @coupon = Coupon.find(params[:id])
    end

    def coupon_params
      params.require(:coupon).permit(:coupon_code, :start_date, :end_date, :coupon_type, :coupon_value, :use_count, :notes)
    end
end
