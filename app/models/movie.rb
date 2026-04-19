class Movie < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  QUIZ_TOP_GROSSING_PER_YEAR = 20

  # Associations
  has_many :roles
  has_many :actors, through: :roles
  has_many :favorite_actors, through: :actors
  has_many :watchlist_items, dependent: :destroy
  has_many :viewings, dependent: :destroy
  has_many :list_items, dependent: :destroy
  has_many :lists, through: :list_items
  has_many :movie_likes, dependent: :destroy


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

  # Quiz pool: top N highest-grossing movies per release year.
  # Keep N configurable via QUIZ_TOP_GROSSING_PER_YEAR.
  scope :top_grossing_per_year_pool, ->(limit_per_year = QUIZ_TOP_GROSSING_PER_YEAR) {
    per_year_limit = [limit_per_year.to_i, 1].max

    where.not(release_date: nil).where(
      <<~SQL,
        movies.id IN (
          SELECT id
          FROM (
            SELECT
              id,
              ROW_NUMBER() OVER (
                PARTITION BY EXTRACT(YEAR FROM release_date)
                ORDER BY COALESCE(revenue, 0) DESC, id ASC
              ) AS yearly_rank
            FROM movies
            WHERE release_date IS NOT NULL
          ) ranked_movies
          WHERE yearly_rank <= ?
        )
      SQL
      per_year_limit
    )
  }

  scope :quiz_eligible, -> {
    top_grossing_per_year_pool
      .where.not(genres: [nil, ""])
      .where("genres NOT ILIKE ?", "%documentary%")
  }

  # Weighted-random selection for quiz questions from the eligible pool.
  scope :random_popular, ->(n) {
    quiz_eligible.order(Arel.sql('-LN(1 - RANDOM()) / GREATEST(COALESCE(popularity, 0.1), 0.1)')).limit(n)
  }

  def release_year
    release_date&.year
  end

  # Highest-grossing first, then deterministic tie-breakers.
  scope :highest_grossing_first, lambda {
    order(Arel.sql('COALESCE(revenue, 0) DESC'), release_date: :desc, title: :asc)
  }

  # Scope for movies released in a specific year
  scope :released_in_year, ->(year) { where("EXTRACT(YEAR FROM release_date) = ?", year) }

  # Scope for movies seen and unseen
  scope :seen, -> { joins(:viewings).distinct }
  scope :unseen, -> { left_joins(:viewings).where(viewings: { id: nil }) }

  # User-scoped: movies this user hasn't watched
  scope :unseen_by, ->(user) {
    where.not(id: Viewing.where(user_id: user.id).select(:movie_id))
  }

  # Movies with a runtime of 60 minutes or more
  scope :feature_length, -> { where("runtime >= ?", 60) }

  # Length scopes for Watch Quiz
  scope :under_90, -> { where("runtime < ?", 90) }
  scope :at_least_90, -> { where("runtime >= ?", 90) }

  # Decade scope
  scope :released_in_decade, ->(decade_start) {
    where(release_date: Date.new(decade_start, 1, 1)..Date.new(decade_start + 9, 12, 31))
  }

  # Collection scopes
  scope :standalones, -> { where(tmdb_collection_id: nil) }
  scope :in_a_collection, -> { where.not(tmdb_collection_id: nil) }

  # Orphan-sequel rule: exclude sequels whose prior entries the user hasn't seen,
  # unless the movie is on the user's watchlist.
  def self.without_orphan_sequels_for(user)
    standalone_sql = "movies.tmdb_collection_id IS NULL"

    earliest_in_collection_sql = <<~SQL.squish
      movies.release_date = (
        SELECT MIN(m2.release_date)
        FROM movies m2
        WHERE m2.tmdb_collection_id = movies.tmdb_collection_id
          AND m2.release_date IS NOT NULL
      )
    SQL

    all_priors_seen_sql = <<~SQL.squish
      NOT EXISTS (
        SELECT 1 FROM movies m3
        WHERE m3.tmdb_collection_id = movies.tmdb_collection_id
          AND m3.release_date < movies.release_date
          AND m3.release_date IS NOT NULL
          AND NOT EXISTS (
            SELECT 1 FROM viewings v
            WHERE v.movie_id = m3.id AND v.user_id = ?
          )
      )
    SQL

    on_watchlist_sql = <<~SQL.squish
      EXISTS (
        SELECT 1 FROM watchlist_items wi
        WHERE wi.movie_id = movies.id AND wi.user_id = ?
      )
    SQL

    where(
      "#{standalone_sql} OR #{earliest_in_collection_sql} OR (#{all_priors_seen_sql}) OR (#{on_watchlist_sql})",
      user.id, user.id
    )
  end

  # Movies that feature at least one favorite actor.
  #
  # If a user is provided, it filters to that user's favorite actors.
  # Otherwise, it matches any favorite actor record.
  scope :with_favorite_actors, ->(user = nil) {
    scope = joins(roles: { actor: :favorite_actors })
    scope = scope.where(favorite_actors: { user_id: user.id }) if user
    scope.distinct
  }

  # Fast random movie selection compatible with DISTINCT and joins
  scope :random_one, -> {
    from(
      select(:id).order(Arel.sql("RANDOM()")).limit(1),
      :movies
    )
  }

  # Scope for movies that are available on at least one streaming platform.
  #
  # This scope evaluates availability via WatchAvailabilityService, which
  # queries an external API and uses per-movie caching. Because this cannot
  # be expressed in SQL, the scope resolves to a list of matching IDs.
  #
  # Usage:
  #   Movie.available
  #
scope :available_via_api, lambda {
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

  # Pitch line for Watch Quiz final step
  def pitch_line(user:)
    role = best_pitch_role(user)
    genre = pick_pitch_genre
    cast_names = top_cast_names

    unless role
      return "#{genre} featuring #{cast_names.join(', ')}" if cast_names.any?

      return "#{genre} with a standout performance"
    end

    supporting_cast = top_cast_names(exclude: role.actor.name)

    if role.age_during_filming.blank? || role.age_during_filming < 15
      if supporting_cast.any?
        "#{genre} starring #{role.actor.name}. Also featuring #{supporting_cast.join(', ')}"
      else
        "#{genre} starring #{role.actor.name}"
      end
    else
      if supporting_cast.any?
        "#{genre} with #{role.age_during_filming}-year-old #{role.actor.name}. Also featuring #{supporting_cast.join(', ')}"
      else
        "#{genre} with #{role.age_during_filming}-year-old #{role.actor.name}"
      end
    end
  end

  private

  PUNCHY_GENRES = %w[Horror Thriller Romance Comedy Action].freeze

  def best_pitch_role(user)
    favorite_role = roles.joins(:actor).merge(Actor.joins(:favorite_actors).where(favorite_actors: { user_id: user.id })).first
    return favorite_role if favorite_role

    roles.order(:id).first
  end

  def pick_pitch_genre
    return "A wild-card pick" if genres.blank?
    return genres.split(",").first.strip if genres.split(",").size == 1

    parts = genres.split(",").map(&:strip)
    punchy = parts.select { |g| PUNCHY_GENRES.include?(g) }
    punchy.any? ? punchy.first : parts.first
  end

  def top_cast_names(limit = 3, exclude: nil)
    scope = roles.joins(:actor).order(:id)
    scope = scope.where.not(actors: { name: exclude }) if exclude.present?

    scope.limit(limit)
         .pluck("actors.name")
         .compact
         .reject(&:blank?)
         .uniq
  end

  
end
