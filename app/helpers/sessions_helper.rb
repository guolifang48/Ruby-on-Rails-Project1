module SessionsHelper

  def sign_in(user, permanent = false)
    session_token = User.new_session_token
    if permanent
      cookies.permanent[:session_token] = session_token
    else
      cookies[:session_token] = session_token
    end
    user.update_attribute(:session_token, User.encrypt(session_token))
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    session_token = User.encrypt(cookies[:session_token])
    @current_user ||= User.find_by_session_token(session_token)
  end

  def create_and_signin_guest
    if current_user.blank?
      user = User.new(guest:true)
      user.save(validate:false)
      sign_in(user)
    end
  end

  def current_user?(user)
    user == current_user
  end

  def signed_in_user
    unless signed_in?
      store_location
      flash[:error] = "Please sign in."
      redirect_to login_url
    end
  end

  def sign_out
    current_user = nil
    cookies.delete(:session_token)
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end
end