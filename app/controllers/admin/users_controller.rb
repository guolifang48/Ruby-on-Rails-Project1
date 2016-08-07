class Admin::UsersController < ApplicationController
  before_action :authorize_admin

  def index
    @users = User.non_guest.order(created_at: :desc).paginate(:page => params[:page], :per_page => 250)
  end

  def update
    @user = User.find(params[:id])
    @user.update(user_params)
    respond_to do |format|
      format.js {}
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.prepare_for_destroy
    @user.destroy
    respond_to do |format|
      format.js {}
    end
  end


  def toggle_admin
    user = User.find(params[:id])

    if user.has_role? :admin
      user.remove_role :admin
    else
      user.add_role :admin
    end

    @user = User.find(params[:id])

    respond_to do |format|
      format.js {
        render { 'toggle_admin' }
      }
    end

  end

  private

  def user_params
    params.require(:user).permit(:verification)
  end

end
