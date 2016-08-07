class SessionsController < ApplicationController
  skip_before_filter :signed_in_user, :except => [:destroy]

  def new
    @body_class = 'login'
    respond_to do |format|
      format.html {}
      format.js {}
    end
  end

  def create
    @body_class = 'login'
    user = User.find_by_email(params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      current_user.move_cart_to(user)
      sign_in(user, params[:remember_me])
      if params[:session][:origin] == 'payment'
        redirect_to payment_order_path(@cart)
      else
        redirect_back_or root_path
      end
    else
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
