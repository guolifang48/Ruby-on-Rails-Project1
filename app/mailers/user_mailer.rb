class UserMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  layout 'email_layout'
  default from: "SpareDeck<help@sparedeck.com>"

  # def welcome(user)
  #   @user = user
  #   mail to: user.email, subject: "Welcome to SpareDeck!"
  # end

  def password_reset(user)
    @user = user
    mail :to => user.email, :subject => "SpareDeck password reset"
  end

end
