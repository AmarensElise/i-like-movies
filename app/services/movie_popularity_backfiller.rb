class MoviePopularityBackfiller
  def self.call
    updated = 0
    failed  = 0
    skipped = 0

    Movie.find_each do |movie|
      unless movie.tmdb_id.present?
        skipped += 1
        next
      end

      data = TmdbService.fetch_movie(movie.tmdb_id)

      unless data
        skipped += 1
        next
      end

      movie.update!(
        popularity: data['popularity'],
        vote_count: data['vote_count'],
        revenue:    data['revenue']
      )
      updated += 1
    rescue => e
      Rails.logger.error("[MoviePopularityBackfiller] Failed for Movie##{movie.id}: #{e.message}")
      failed += 1
    ensure
      sleep 0.25
    end

    { updated: updated, failed: failed, skipped: skipped }
  end
end
