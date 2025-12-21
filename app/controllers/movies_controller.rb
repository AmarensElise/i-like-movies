class MoviesController < ApplicationController
  def index
    @movies = Movie.order(created_at: :desc).limit(20)

    # Update missing information for display movies
    @movies.each do |movie|
      if movie.runtime.nil? || movie.vote_average.nil?
        movie_data = TmdbService.fetch_movie(movie.tmdb_id)
        if movie_data.present?
          movie.update(
            runtime: movie_data['runtime'],
            vote_average: movie_data['vote_average']
          )
        end
      end
    end

    @popular_movies = @movies  # Use the same movies as popular movies for now
  end

def show
  # First try to find by database ID
  @movie = Movie.find_by(id: params[:id])
  # If not found by id, try to find by TMDB ID
  if @movie.nil?
    @movie = Movie.find_by(tmdb_id: params[:id])
  end
  # If still not found, try to fetch from TMDB
  if @movie.nil?
    begin
      movie_data = TmdbService.fetch_movie(params[:id])
      if movie_data.present? && movie_data['id'].present?
        # Create the movie record with additional details
        @movie = Movie.create!(
          tmdb_id: movie_data['id'],
          title: movie_data['title'],
          release_date: movie_data['release_date'],
          poster_path: movie_data['poster_path'],
          runtime: movie_data['runtime'],
          vote_average: movie_data['vote_average']
        )
        # Fetch cast information
        fetch_and_save_cast(@movie)
        flash[:notice] = "Movie added to the database"
      else
        flash[:alert] = "Movie not found in TMDB"
        redirect_to search_path
        return
      end
    rescue => e
      Rails.logger.error("Error fetching movie: #{e.message}")
      flash[:alert] = "Error fetching movie details"
      redirect_to search_path
      return
    end
  end

  # Update existing movies that might be missing these details
  if @movie.runtime.nil? || @movie.vote_average.nil?
    movie_data = TmdbService.fetch_movie(@movie.tmdb_id)
    if movie_data.present?
      @movie.update(
        runtime: movie_data['runtime'],
        vote_average: movie_data['vote_average']
      )
    end
  end

  # Load the cast (actors and their roles)
  @cast = @movie.roles.includes(:actor).order(:id)
  # Get additional details from TMDB for the view
  @movie_details = TmdbService.fetch_movie(@movie.tmdb_id)
end

def watchlist
  @movies = Movie.joins(:watchlist_items).order(runtime: :asc)
end

  private

  def fetch_and_save_cast(movie)
    cast_data = TmdbService.fetch_movie_credits(movie.tmdb_id)

    # Ensure we have cast data
    return unless cast_data && cast_data['cast'].is_a?(Array)

    cast_data['cast'].each do |cast_member|
      next unless cast_member['id'].present? && cast_member['name'].present?

      # Find or create the actor
      actor = Actor.find_by(tmdb_id: cast_member['id'])

      if actor.nil?
        actor_details = TmdbService.fetch_person(cast_member['id'])

        actor = Actor.create!(
          tmdb_id: cast_member['id'],
          name: cast_member['name'],
          birthday: actor_details['birthday']
        )
      end

      # Create the role if it doesn't exist
      unless Role.exists?(movie: movie, actor: actor)
        Role.create!(
          movie: movie,
          actor: actor,
          character: cast_member['character'],
          age_during_filming: calculate_age_during_filming(actor.birthday, movie.release_date)
        )
      end
    end
  rescue => e
    Rails.logger.error("Error saving cast: #{e.message}")
    # Continue without cast if there's an error
  end

  def calculate_age_during_filming(birthday, release_date)
    return nil if birthday.nil? || release_date.nil?

    release_year = release_date.year
    birthday_year = birthday.year

    age = release_year - birthday_year

    # Adjust for month and day
    if release_date.month < birthday.month ||
       (release_date.month == birthday.month && release_date.day < birthday.day)
      age -= 1
    end

    age
  end
end
