class Admin::VerificationQuizzesController < ApplicationController
  before_action :authorize_admin

  def show
    @verification_quiz = VerificationQuiz.find(params[:id])
    @user = @verification_quiz.user
    respond_to do |format|
      format.html {}
    end
  end

end
