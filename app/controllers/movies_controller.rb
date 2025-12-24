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
        #fetch_and_save_cast(@movie)
        #flash[:notice] = "Movie added to the database"
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

  if @movie.roles.count <= 1
   # fetch_and_save_cast(@movie)
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
  # @cast = @movie.roles.includes(:actor).order(:id)
  # Get additional details from TMDB for the view
  @movie_details = TmdbService.fetch_movie(@movie.tmdb_id)
  @watch_providers = WatchAvailabilityService.new(@movie).call  # If not found by id, try to find by TMDB ID
end

def cast
  # First try to find by database ID
  @movie = Movie.find_by(id: params[:id])
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

  if @movie.roles.count <= 1
    fetch_and_save_cast(@movie)
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
  @watch_providers = WatchAvailabilityService.new(@movie).call  # If not found by id, try to find by TMDB ID
end

def watchlist
  # Load watchlist items (with their movie) so we can show the pitch stored
  # on the watchlist_item and avoid N+1 queries when rendering the view.
  @watchlist_items = WatchlistItem.joins(:movie).includes(:movie).order('movies.runtime ASC')
end

def pitch
  movie_id = WatchlistItem.order(Arel.sql('RANDOM()')).limit(1).pluck(:movie_id).first

  unless movie_id
    flash[:alert] = "Your watchlist is empty"
    redirect_to movies_path
    return
  end

  @movie = Movie.find(movie_id)

  @movie_details = TmdbService.fetch_movie(@movie.tmdb_id)
  @cast = @movie.roles.includes(:actor).order(:id)
  @watch_providers = WatchAvailabilityService.new(@movie).call
  @watchlist_item = WatchlistItem.find_by(movie: @movie)
end

  # POST /movies/:id/fetch_cast
  # Called via AJAX to fetch cast from TMDB (and save to DB) and return
  # the rendered cast partial HTML fragment.
  def fetch_cast
    @movie = Movie.find(params[:id])

    # fetch_and_save_cast is a private method that handles TMDB lookup and
    # creating Actor/Role records as needed.
    fetch_and_save_cast(@movie)

    @cast = @movie.roles.includes(:actor).order(:id)

    render partial: 'movies/cast', locals: { cast: @cast }
  rescue ActiveRecord::RecordNotFound
    head :not_found
  rescue => e
    Rails.logger.error("Error in fetch_cast: #{e.message}")
    head :internal_server_error
  end

  # GET /movies/:id/cast
  # Render a dedicated cast page for the movie. If the cast isn't present
  # yet, enqueue the background job and render a page that will poll for the
  # cast and display it once ready.
  def cast
    @movie = Movie.find(params[:id])

    if @movie.roles.count <= 1
       fetch_and_save_cast(@movie)
    end

    @watch_providers = WatchAvailabilityService.new(@movie).call
    @cast = @movie.roles.includes(:actor).order(:id)
    # Render app/views/movies/cast.html.erb
  end

def actor_pitch
  movie_ids = Movie
    .with_favorite_actors
    .unseen
    .feature_length
    .pluck(:id)

  if movie_ids.empty?
    flash[:alert] = "No unseen movies found for your favorite actors"
    redirect_to actors_path
    return
  end

  @movie = Movie.find(movie_ids.sample)

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

  @movie_details = TmdbService.fetch_movie(@movie.tmdb_id)
  @cast = @movie.roles.includes(:actor).order(:id)
  @watch_providers = WatchAvailabilityService.new(@movie).call
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
