# app/services/tmdb/actor_filmography_importer.rb
class ActorFilmographyImporter
  def initialize(actor)
    @actor = actor
  end

  def call
    credits = TmdbService.fetch_person_credits(@actor.tmdb_id)
    import_cast_roles(credits['cast'])
  end

  private

  def import_cast_roles(cast_movies)
    cast_movies.each do |movie_data|
      movie = Movie.find_or_create_by!(tmdb_id: movie_data['id']) do |m|
        m.title        = movie_data['title']
        m.release_date = movie_data['release_date']
        m.poster_path  = movie_data['poster_path']
        m.vote_average = movie_data['vote_average']
      end

      Role.find_or_create_by!(
        actor: @actor,
        movie: movie
      ) do |role|
        role.character = movie_data['character']
      end
    end
  end
end