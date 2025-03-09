class Movie < ApplicationRecord
  # Associations
  has_many :roles
  has_many :actors, through: :roles

  # Validations
  validates :tmdb_id, presence: true, uniqueness: true
  validates :title, presence: true

  # Scope for recent movies
  scope :recent, -> { order(created_at: :desc) }

  # Scope for movies released in a specific year
  scope :released_in_year, ->(year) { where("EXTRACT(YEAR FROM release_date) = ?", year) }
end
