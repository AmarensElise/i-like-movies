class Quiz < ApplicationRecord
  belongs_to :user
  has_many :quiz_questions, -> { order(:position) }, dependent: :destroy
  has_many :movies, through: :quiz_questions

  scope :in_progress, -> { where(status: 'in_progress') }
  scope :completed,   -> { where(status: 'completed') }

  def current_question
    quiz_questions.find_by(answered_at: nil)
  end

  def finished?
    quiz_questions.count == 10 && quiz_questions.where(answered_at: nil).none?
  end

  def finalize!
    update!(
      total_score: quiz_questions.sum(:points_earned).to_i,
      status: 'completed',
      completed_at: Time.current
    )
  end

  def self.start_for(user)
    transaction do
      existing = user.quizzes.in_progress.first
      return existing if existing

      movies = Movie.random_popular(10).to_a
      raise "Not enough eligible movies to start a quiz (need 10, got #{movies.size})" if movies.size < 10

      quiz = user.quizzes.create!(started_at: Time.current)
      movies.each_with_index do |movie, i|
        quiz.quiz_questions.create!(movie: movie, position: i + 1)
      end
      quiz
    end
  end
end
