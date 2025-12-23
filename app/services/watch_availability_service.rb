class WatchAvailabilityService
  REGIONS = %w[
    ES MX AU GB SK US BR IS NO AR PT CA FI DK BG EE FR NL BE DE CZ LV AT PL RO IE HU HR IT PH GR
  ].freeze

  def initialize(movie)
    @movie = movie
  end

  def call
    Rails.cache.fetch(cache_key, expires_in: 24.hours) do
      raw = TmdbService.fetch_watch_providers(@movie.tmdb_id)
      extract_regions(raw, REGIONS)
    end
  end

  private

  def extract_regions(raw, regions)
    return {} unless raw.is_a?(Hash)

    regions.each_with_object({}) do |region, result|
      flatrate = raw.dig(region, "flatrate")
      next unless flatrate.present?

      result[region] = flatrate.map { |p| p["provider_name"] }
    end
  end

  def cache_key
    "watch_providers/#{@movie.tmdb_id}/streaming_only/v2"
  end
end