class WatchQuizSession < ApplicationRecord
  belongs_to :user
  belongs_to :chosen_movie, class_name: "Movie", optional: true
  belongs_to :rejected_movie, class_name: "Movie", optional: true

  def completed?
    completed_at.present?
  end
end
