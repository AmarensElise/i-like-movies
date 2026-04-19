class QuizQuestionsController < ApplicationController
  before_action :authenticate_user!

  def update
    quiz     = current_user.quizzes.find(params[:quiz_id])
    @question = quiz.quiz_questions.find(params[:id])

    if @question.answered_at.present?
      head :unprocessable_entity
      return
    end

    year = guessed_year_param.to_i
    @question.submit_guess!(year)
    @quiz = quiz

    respond_to do |format|
      format.turbo_stream
    end
  rescue ActiveRecord::RecordInvalid, ArgumentError
    head :unprocessable_entity
  end

  private

  def guessed_year_param
    nested = params[:quiz_question]
    return nested.permit(:guessed_year)[:guessed_year] if nested.present?

    params[:guessed_year]
  end
end
