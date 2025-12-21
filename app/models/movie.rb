class Movie < ApplicationRecord
  # Associations
  has_many :roles
  has_many :actors, through: :roles
  has_many :watchlist_items, dependent: :destroy
  has_many :viewings, dependent: :destroy


  # Validations
  validates :tmdb_id, presence: true, uniqueness: true
  validates :title, presence: true

  def on_watchlist?
    watchlist_items.exists?
  end

  def seen?
    viewings.exists?
  end

  # Scope for recent movies
  scope :recent, -> { order(created_at: :desc) }

  # Scope for movies released in a specific year
  scope :released_in_year, ->(year) { where("EXTRACT(YEAR FROM release_date) = ?", year) }

  # Scope for movies seen and unseen
  scope :seen, -> { joins(:viewings).distinct }
  scope :unseen, -> { left_joins(:viewings).where(viewings: { id: nil }) }
end
