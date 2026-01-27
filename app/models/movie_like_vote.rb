class MovieLikeVote < ApplicationRecord
  belongs_to :user
  belongs_to :movie_like

  validates :user_id, uniqueness: { scope: :movie_like_id, message: "has already voted on this" }
end
