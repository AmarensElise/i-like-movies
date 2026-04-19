class QuizzesController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    @quiz = Quiz.start_for(current_user)
    redirect_to quiz_path(@quiz)
  rescue => e
    flash[:alert] = e.message
    redirect_to new_quiz_path
  end

  def show
    @quiz = current_user.quizzes.find(params[:id])
    @question = @quiz.current_question unless @quiz.finished?
  end
end
