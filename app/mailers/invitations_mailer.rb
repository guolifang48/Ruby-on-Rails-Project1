class InvitationsMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  layout 'email_layout'
  default from: "SpareDeck<help@sparedeck.com>"

  def requested_invitation(invitation)
    @signup_url = signup_url(invitation.token)
    @invitation = invitation
    time = Time.now.in_time_zone("UTC").to_datetime
    @invitation.update_columns(sent_at:time)

    mail(to: invitation.recipient_email, subject: 'SpareDeck registration link')
  end

end
