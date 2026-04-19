class MoviePicker
  STREAMING_LIMIT = 100

  def initialize(user:, filters: {})
    @user = user
    @filters = filters
  end

  def call
    scope = base_scope
    scope = apply_streaming(scope)
    scope
  end

  def call_without_streaming
    base_scope
  end

  private

  def base_scope
    scope = Movie.top_grossing_per_year_pool
           .where("release_date >= ?", Date.new(1990, 1, 1))
           .where("COALESCE(genres, '') NOT ILIKE ?", "%documentary%")
           .unseen_by(@user)
    scope = Movie.without_orphan_sequels_for(@user).merge(scope)
    scope = apply_length(scope)
    scope = apply_adventurousness(scope)
    scope = apply_category_filters(scope)
    scope
  end

  def apply_length(scope)
    case @filters[:length]
    when "under_90" then scope.under_90
    when "over_90"  then scope.at_least_90
    else scope
    end
  end

  def apply_adventurousness(scope)
    case @filters[:adventurousness]
    when "comfort_zone"
      scope.joins(:watchlist_items)
           .where(watchlist_items: { user_id: @user.id })
           .with_favorite_actors(@user)
    when "lean_familiar"
      # Boost watchlist and favorite-actor movies to the top via ordering.
      # The relation itself is unfiltered so the pool stays large.
      scope.left_joins(:watchlist_items)
           .order(
             Arel.sql(<<~SQL.squish)
               CASE WHEN watchlist_items.id IS NOT NULL AND watchlist_items.user_id = #{@user.id} THEN 0 ELSE 1 END,
               COALESCE(movies.popularity, 0) DESC
             SQL
           )
    else
      scope
    end
  end

  def apply_category_filters(scope)
    scope = apply_decade(scope)
    scope = apply_collection(scope)
    scope = apply_popularity(scope)
    scope = apply_vote_average(scope)
    scope
  end

  def apply_decade(scope)
    return scope unless @filters[:decade]
    scope.released_in_decade(@filters[:decade].to_i)
  end

  def apply_collection(scope)
    case @filters[:collection]
    when "none"  then scope.standalones
    when "first"
      scope.in_a_collection.where(
        <<~SQL.squish
          movies.release_date = (
            SELECT MIN(m2.release_date)
            FROM movies m2
            WHERE m2.tmdb_collection_id = movies.tmdb_collection_id
              AND m2.release_date IS NOT NULL
          )
        SQL
      )
    else scope
    end
  end

  def apply_popularity(scope)
    case @filters[:popularity]
    when "low"
      scope.where("COALESCE(popularity, 0) < ?", 20)
    else scope
    end
  end

  def apply_vote_average(scope)
    return scope unless @filters[:vote_average_min]
    scope.where("COALESCE(vote_average, 0) >= ?", @filters[:vote_average_min].to_f)
  end

  def apply_streaming(scope)
    case @filters[:streaming]
    when "domestic"
      region = @user.country_code
      return scope if region.blank?
      filter_by_streaming(scope, [region])
    when "vpn_ok"
      filter_by_streaming(scope, Movie::STREAMING_REGIONS)
    else
      scope
    end
  end

  def filter_by_streaming(scope, regions)
    ids = scope.limit(STREAMING_LIMIT).pluck(:id).select do |id|
      movie = Movie.find(id)
      providers_by_region = WatchAvailabilityService.new(movie).call
      next false if providers_by_region.blank?

      providers_by_region.any? do |region, providers|
        regions.include?(region) &&
          (providers & Movie::STREAMING_PROVIDERS).any?
      end
    end
    Movie.where(id: ids)
  end
end
