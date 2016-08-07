class PasswordResetsController < ApplicationController

  def create
    user = User.find_by_email(params[:email])
    user.send_password_reset if user
    flash[:success] = "Email sent with password reset instructions."
    if signed_in? && !current_user.guest?
      redirect_to account_url
    else
      redirect_to root_url
    end
  end

  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.password_reset_sent_at < 2.hours.ago
      flash[:error] = "Password reset has expired."
      redirect_to root_url
    elsif @user.update_attributes(user_params)
      flash[:success] = "Password has been reset!"
      if signed_in?
        redirect_to account_url
      else
        redirect_to root_url
      end
    else
      @errors = @user.errors.full_messages.join(" | ")
      flash[:error] = @errors
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

end
