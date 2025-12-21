class Actor < ApplicationRecord
  # Associations
  has_many :roles
  has_many :movies, through: :roles
  has_many :favorite_actors, dependent: :destroy

  # Validations
  validates :tmdb_id, presence: true, uniqueness: true
  validates :name, presence: true

  def favorited?
    favorite_actors.exists?
  end
end
