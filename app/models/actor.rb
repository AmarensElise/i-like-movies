class Actor < ApplicationRecord
  # Associations
  has_many :roles
  has_many :movies, through: :roles
  has_many :favorite_actors, dependent: :destroy

  # Validations
  validates :tmdb_id, presence: true, uniqueness: true
  validates :name, presence: true

  # Returns whether this actor is favorited by the given user.
  #
  # If no user is provided, it returns false (so we don't accidentally
  # treat "favorited" as a global state across all users).
  def favorited?(user = nil)
    return false unless user

    favorite_actors.where(user_id: user.id).exists?
  end
end
