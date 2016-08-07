class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include SessionsHelper
  before_action :create_and_signin_guest
  before_action :load_or_create_cart
  around_filter :user_time_zone if :user_is_not_guest
  protect_from_forgery with: :exception

  def authorize_admin
    if (current_user && (current_user.has_role? :admin))
      true
    else
      flash[:error] = "unauthorized access"
      redirect_to root_url
      false
    end
  end

  def user_is_not_guest
    current_user.guest == true ? false : true
  end

  def test
    current_user.move_cart_to(User.last)
  end

  def load_or_create_cart
    @cart = current_user.orders.last_cart
    if @cart.blank?
      @cart = current_user.orders.build
      @cart.save
    end
  end

  private

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

end
