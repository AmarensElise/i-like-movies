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

  STREAMING_PROVIDERS = [
  "Netflix",
  "Amazon Prime Video",
  "Disney Plus"
].freeze

STREAMING_REGIONS = ["MX", "AU", "GB", "SK", "US", "BR", "IS", "NO", "AR", "PT", "CA", "FI", "DK", "BG", "EE", "FR", "NL", "BE", "DE", "CZ", "LV", "AT", "PL", "RO", "IE", "HU", "HR", "IT", "PH", "GR"].freeze

  # Scope for recent movies
  scope :recent, -> { order(created_at: :desc) }

  # Scope for movies released in a specific year
  scope :released_in_year, ->(year) { where("EXTRACT(YEAR FROM release_date) = ?", year) }

  # Scope for movies seen and unseen
  scope :seen, -> { joins(:viewings).distinct }
  scope :unseen, -> { left_joins(:viewings).where(viewings: { id: nil }) }

  # Scope for movies that are available on at least one streaming platform.
  #
  # This scope evaluates availability via WatchAvailabilityService, which
  # queries an external API and uses per-movie caching. Because this cannot
  # be expressed in SQL, the scope resolves to a list of matching IDs.
  #
  # Usage:
  #   Movie.available
  #
scope :available, lambda {
  available_ids = []

  find_each do |movie|
    providers_by_region = WatchAvailabilityService.new(movie).call
    next if providers_by_region.blank?

    is_available = providers_by_region.any? do |region, providers|
      STREAMING_REGIONS.include?(region) &&
        (providers & STREAMING_PROVIDERS).any?
    end

    available_ids << movie.id if is_available
  end

  where(id: available_ids)
}

  
end
