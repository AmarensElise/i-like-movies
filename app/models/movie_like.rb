class MovieLike < ApplicationRecord
  belongs_to :user
  belongs_to :movie
  has_many :movie_like_votes, dependent: :destroy
  has_many :voters, through: :movie_like_votes, source: :user

  validates :content, presence: true, length: { minimum: 3, maximum: 500 }

  def votes_count
    movie_like_votes.count
  end

  def voted_by?(user)
    return false unless user
    movie_like_votes.exists?(user_id: user.id)
  end
end
