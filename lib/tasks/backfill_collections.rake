desc "Backfill tmdb_collection_id and tmdb_collection_name for movies"
namespace :movies do
  task backfill_collections: :environment do
    Movie.where(tmdb_collection_id: nil).find_each do |movie|
      details = TmdbService.fetch_movie(movie.tmdb_id)
      next unless details

      collection = details["belongs_to_collection"]
      next unless collection.present?

      movie.update_columns(
        tmdb_collection_id: collection["id"],
        tmdb_collection_name: collection["name"]
      )
      print "."
    end
    puts "\nDone."
  end
end
