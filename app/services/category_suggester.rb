class CategorySuggester
  TEMPLATES = [
    { key: :decade_80s,      label: "80s picks",         filters: { decade: 1980 } },
    { key: :decade_90s,      label: "90s picks",         filters: { decade: 1990 } },
    { key: :decade_2000s,    label: "2000s gems",        filters: { decade: 2000 } },
    { key: :decade_2010s,    label: "2010s favorites",   filters: { decade: 2010 } },
    { key: :standalones,     label: "Just a standalone",  filters: { collection: "none" } },
    { key: :franchise_start, label: "Start a franchise",  filters: { collection: "first" } },
    { key: :hidden_gems,     label: "Hidden gems",        filters: { popularity: "low" } },
    { key: :crowd_pleasers,  label: "Crowd pleasers",     filters: { vote_average_min: 7.5 } }
  ].freeze

  MIN_POOL_SIZE = 5
  DEFAULT_COUNT = 3

  def initialize(user:, base_filters:, count: DEFAULT_COUNT, seed: nil)
    @user = user
    @base_filters = base_filters
    @count = count
    @seed = seed || SecureRandom.hex(4)
  end

  def call
    eligible = TEMPLATES.select do |tpl|
      MoviePicker.new(
        user: @user,
        filters: @base_filters.merge(tpl[:filters])
      ).call_without_streaming.limit(MIN_POOL_SIZE).count >= MIN_POOL_SIZE
    end
    rng = Random.new(@seed.to_s.hash)
    eligible.sample(@count, random: rng)
  end
end
