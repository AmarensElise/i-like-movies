class Actor < ApplicationRecord
  # Associations
  has_many :roles
  has_many :movies, through: :roles

  # Validations
  validates :tmdb_id, presence: true, uniqueness: true
  validates :name, presence: true
end
