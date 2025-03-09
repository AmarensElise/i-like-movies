class Role < ApplicationRecord
  # Associations
  belongs_to :movie
  belongs_to :actor

  # Validations
  validates :movie_id, uniqueness: { scope: :actor_id, message: "Actor already has a role in this movie" }
end
