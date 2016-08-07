class VerificationQuizzesController < ApplicationController

  def new
    respond_to do |format|
      format.html {
        if current_user.primary_verification_quiz.blank?
          @verification_quiz = current_user.verification_quizzes.build
          render 'new'
        else
          flash[:success] = 'You\'ve already completed the verification questions.'
          redirect_to account_url
        end
      }
    end
  end

  def create
    @verification_quiz = current_user.verification_quizzes.build(verification_quiz_params)
    @verification_quiz.save

    respond_to do |format|
      format.html {
        flash[:success] = 'Answers received, Thanks!'
        redirect_to account_url
      }
    end
  end

  private

  def verification_quiz_params
    params.require(:verification_quiz).permit(
      :answer_1,
      :answer_2,
      :answer_3,
      :answer_4,
      :answer_5
    )
  end

end
