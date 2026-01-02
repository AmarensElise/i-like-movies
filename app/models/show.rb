class Show < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  has_many :show_roles, dependent: :destroy
  has_many :actors, through: :show_roles

  validates :tmdb_id, presence: true, uniqueness: true
  validates :name, presence: true

  def start_year
    first_air_date&.year
  end

  def end_year
    last_air_date&.year || first_air_date&.year
  end

  def media_type
    'tv'
  end
end
