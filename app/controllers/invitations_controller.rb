class InvitationsController < ApplicationController

  def new
    @invitation = Invitation.new
    respond_to do |format|
      format.js {}
    end
  end

  def create
    @invitation = Invitation.new(invitation_params)

    if current_user && current_user.guest
      @invitation.guest_id = current_user.id
    end

    if @invitation.save
      respond_to do |format|
        InvitationsMailer.requested_invitation(@invitation).deliver
        format.js {}
      end
    else
      @errors = @invitation.errors.full_messages.first
      respond_to do |format|
        format.js { render 'error' }
      end
    end

  end

  private

    def invitation_params
      params.require(:invitation).permit(:recipient_email, :origin)
    end

end
