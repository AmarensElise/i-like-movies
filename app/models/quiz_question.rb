class QuizQuestion < ApplicationRecord
  belongs_to :quiz
  belongs_to :movie

  validates :guessed_year,
    numericality: { only_integer: true, greater_than_or_equal_to: 1900, less_than_or_equal_to: Date.current.year },
    allow_nil: true

  def actual_year
    movie.release_year
  end

  def submit_guess!(year)
    raise "Question already answered" if answered_at.present?

    self.guessed_year = year
    self.answered_at  = Time.current
    self.points_earned = (year - actual_year).abs
    save!

    quiz.finalize! if quiz.finished?
  end
end
