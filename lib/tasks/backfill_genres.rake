desc "Backfill genres for movies that are missing them from TMDB"
namespace :movies do
  task backfill_genres: :environment do
    scope = Movie.where(genres: [nil, ""])
    total = scope.count
    puts "Backfilling genres for #{total} movies..."
    updated = 0
    failed = 0

    scope.find_each do |movie|
      details = TmdbService.fetch_movie(movie.tmdb_id)
      if details
        genre_string = (details["genres"]&.map { |g| g["name"] } || []).join(", ")
        movie.update_columns(genres: genre_string) if genre_string.present?
        print "."
        updated += 1
      else
        print "x"
        failed += 1
      end
      sleep 0.05 # be polite to the API
    end

    puts "\nDone. Updated: #{updated}, Failed: #{failed}"
  end
end
