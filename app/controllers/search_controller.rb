class SearchController < ApplicationController
  def index
    @query = params[:query]

    if @query.present?
      # Search local database first
      @movies = Movie.where("title ILIKE ?", "%#{@query}%").limit(10)
      @shows  = Show.where("name ILIKE ?", "%#{@query}%").limit(10)

      # If not enough results, search TMDB API
      if @movies.count < 5
        tmdb_results = search_tmdb_movies(@query)
        @tmdb_movies = process_tmdb_results(tmdb_results)
      else
        @tmdb_movies = []
      end

      if @shows.count < 5
        tmdb_results = search_tmdb_shows(@query)
        @tmdb_shows = process_tmdb_show_results(tmdb_results)
      else
        @tmdb_shows = []
      end
    else
      @movies = Movie.order(created_at: :desc).limit(10)
      @tmdb_movies = []
      @shows = Show.order(created_at: :desc).limit(10)
      @tmdb_shows = []
    end
  end

  def show
    tmdb_id = params[:id]

    # Try to find movie in local database first
    @movie = Movie.find_by(tmdb_id: tmdb_id)

    # If not found, fetch from TMDB API and save to database
    if @movie.nil?
      movie_data = fetch_tmdb_movie(tmdb_id)

      if movie_data.present?
        @movie = save_movie_from_tmdb(movie_data)
        fetch_and_save_cast(@movie)
      else
        flash[:alert] = "Movie not found"
        redirect_to search_path
        return
      end
    end

    # Load the cast (actors and their roles)
    @cast = @movie.roles.includes(:actor).order(:id)
  end

  private

  def search_tmdb_movies(query)
    # Assuming you have a TMDB service class
    TmdbService.search_movies(query)
  end

  def search_tmdb_shows(query)
    TmdbService.search_tv(query)
  end

  def fetch_tmdb_movie(tmdb_id)
    TmdbService.fetch_movie(tmdb_id)
  end

  def process_tmdb_results(results)
    # Process the TMDB results to match your expected format
    results.map do |result|
      {
        tmdb_id: result['id'],
        title: result['title'],
        release_date: result['release_date'],
        poster_path: result['poster_path']
      }
    end
  end

  def process_tmdb_show_results(results)
    results.map do |result|
      {
        tmdb_id: result['id'],
        name: result['name'],
        first_air_date: result['first_air_date'],
        poster_path: result['poster_path']
      }
    end
  end

  def save_movie_from_tmdb(movie_data)
    Movie.create!(
      tmdb_id: movie_data['id'],
      title: movie_data['title'],
      release_date: movie_data['release_date'],
      poster_path: movie_data['poster_path']
    )
  end

  def fetch_and_save_cast(movie)
    cast_data = TmdbService.fetch_movie_credits(movie.tmdb_id)

    cast_data['cast'].each do |cast_member|
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

      # Create the role
      unless Role.exists?(movie: movie, actor: actor)
        Role.create!(
          movie: movie,
          actor: actor,
          character: cast_member['character'],
          age_during_filming: calculate_age_during_filming(actor.birthday, movie.release_date)
        )
      end
    end
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
