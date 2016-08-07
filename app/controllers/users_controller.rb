class UsersController < ApplicationController
  skip_before_filter :signed_in_user, :only => [:new, :create]
  skip_before_filter :valid_subscription?, :only => [:new, :create]

  def new
    @invitation = Invitation.find_by(token:params[:invitation_token])

    if @invitation.blank?
      redirect_to root_path
    else
      @user = User.new(email:@invitation.recipient_email)
    end
  end

  def create
    #Check that invitation token is valid
    @invitation = Invitation.find_by token: params[:token]
    if @invitation.blank?
      flash[:warning]="Your registration token is no longer valid"
      redirect_to root_path
    end

    @user = User.new(user_params)

    if @user.save

      if @invitation.guest_id.present?
        guest = User.find(@invitation.guest_id)
        if guest.orders.last_cart.present? && guest.orders.last_cart.order_cards.count > 0
          guest.move_cart_to(@user)
        end
      end

      # UserMailer.welcome(@user).deliver
      @invitation.update_columns(registered_at:Time.zone.now)
      sign_in @user

      if @invitation.origin == 'payment' && @user.orders.last_cart.present?
        redirect_to payment_order_url(@user.orders.last_cart)
      else
        redirect_to root_url
      end
    else
      @errors = @user.errors.full_messages.join(" | ")
      flash[:error] = @errors
      redirect_to signup_url(@invitation.token)
    end
  end

  def update
    @user = current_user

    if @user.email != user_params[:email]
      if !@user.authenticate(user_params[:password])
        flash[:error] = 'Invalid password'
        redirect_to '/account'
      else
        if @user.update_attributes(user_params)
          flash[:success] = "Account updated"
          sign_in @user
          redirect_to '/account'
        else
          flash[:error] = @user.errors.collect{|error| error}.join("\n")
          redirect_to '/account'
        end
      end
    else
      if @user.update_attributes(user_params)
        flash[:success] = "Account updated"
        sign_in @user
        redirect_to '/account'
      else
        render 'account'
      end
    end
  end

  def destroy
    current_user.prepare_for_destroy
    current_user.destroy
    flash[:success] = "Your account and associated information has been removed."
    sign_out
    redirect_to root_url
  end

  def account
    @orders = current_user.orders.where("orders.authorized IS NOT NULL").order(created_at: :desc)
  end

  private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :time_zone, :terms) if params[:user]
    end
end