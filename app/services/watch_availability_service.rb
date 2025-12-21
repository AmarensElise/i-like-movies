class WatchAvailabilityService
  REGIONS = %w[NL GB DE FR US UK AU].freeze

  def initialize(movie)
    @movie = movie
  end

  def call
    Rails.cache.fetch(cache_key, expires_in: 24.hours) do
      raw = TmdbService.fetch_watch_providers(@movie.tmdb_id)
      normalize(raw)
    end
  end

  private

  def normalize(raw)
    return {} unless raw.is_a?(Hash)

    REGIONS.each_with_object({}) do |region, result|
      flatrate = raw.dig(region, "flatrate")
      next unless flatrate.present?

      result[region] = flatrate.map { |p| p["provider_name"] }
    end
  end

  def cache_key
    "watch_providers/#{@movie.tmdb_id}/streaming_only"
  end
end