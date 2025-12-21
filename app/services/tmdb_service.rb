class TmdbService
  include HTTParty
  base_uri 'https://api.themoviedb.org/3'

def self.api_key
  ENV.fetch("TMDB_API_KEY")
end

  # Search for movies by query string
  def self.search_movies(query, page = 1)
    response = get('/search/movie', query: {
      api_key: api_key,
      query: query,
      page: page,
      include_adult: false
    })

    response.success? ? response['results'] : []
  end

  # Fetch a specific movie's details
  def self.fetch_movie(tmdb_id)
    response = get("/movie/#{tmdb_id}", query: {
      api_key: api_key,
      append_to_response: 'credits'
    })

    response.success? ? response : nil
  end

  

  # Fetch a movie's credits (cast and crew)
  def self.fetch_movie_credits(tmdb_id)
    response = get("/movie/#{tmdb_id}/credits", query: {
      api_key: api_key
    })

    response.success? ? response : { 'cast' => [] }
  end

  # Fetch details about a person (actor, director, etc.)
  def self.fetch_person(person_id)
    response = get("/person/#{person_id}", query: {
      api_key: api_key
    })

    response.success? ? response : {}
  end

  # Fetch trending movies
  def self.trending_movies(time_window = 'week', page = 1)
    response = get("/trending/movie/#{time_window}", query: {
      api_key: api_key,
      page: page
    })

    response.success? ? response['results'] : []
  end

  # Fetch top rated movies
  def self.top_rated_movies(page = 1)
    response = get("/movie/top_rated", query: {
      api_key: api_key,
      page: page
    })

    response.success? ? response['results'] : []
  end

  # Fetch currently playing movies
  def self.now_playing_movies(page = 1)
    response = get("/movie/now_playing", query: {
      api_key: api_key,
      page: page
    })

    response.success? ? response['results'] : []
  end

  # Fetch upcoming movies
  def self.upcoming_movies(page = 1)
    response = get("/movie/upcoming", query: {
      api_key: api_key,
      page: page
    })

    response.success? ? response['results'] : []
  end

  # Fetch movies by genre
  def self.movies_by_genre(genre_id, page = 1)
    response = get("/discover/movie", query: {
      api_key: api_key,
      with_genres: genre_id,
      sort_by: 'popularity.desc',
      page: page,
      include_adult: false
    })

    response.success? ? response['results'] : []
  end

  # Fetch movies by release year
  def self.movies_by_year(year, page = 1)
    response = get("/discover/movie", query: {
      api_key: api_key,
      primary_release_year: year,
      sort_by: 'popularity.desc',
      page: page,
      include_adult: false
    })

    response.success? ? response['results'] : []
  end

  # Fetch movies by actor
  def self.movies_by_actor(actor_id, page = 1)
    response = get("/discover/movie", query: {
      api_key: api_key,
      with_cast: actor_id,
      sort_by: 'popularity.desc',
      page: page,
      include_adult: false
    })

    response.success? ? response['results'] : []
  end

  # Fetch movie genres list
  def self.fetch_genres
    response = get("/genre/movie/list", query: {
      api_key: api_key
    })

    response.success? ? response['genres'] : []
  end

  # Search for a person (actor, director, etc.)
  def self.search_person(query, page = 1)
    response = get("/search/person", query: {
      api_key: api_key,
      query: query,
      page: page,
      include_adult: false
    })

    response.success? ? response['results'] : []
  end

  # Fetch a person's movie credits
  def self.fetch_person_credits(person_id)
    response = get("/person/#{person_id}/movie_credits", query: {
      api_key: api_key
    })

    response.success? ? response : { 'cast' => [], 'crew' => [] }
  end

  # Fetch similar movies
  def self.fetch_similar_movies(movie_id, page = 1)
    response = get("/movie/#{movie_id}/similar", query: {
      api_key: api_key,
      page: page
    })

    response.success? ? response['results'] : []
  end

  # Fetch movie recommendations
  def self.fetch_movie_recommendations(movie_id, page = 1)
    response = get("/movie/#{movie_id}/recommendations", query: {
      api_key: api_key,
      page: page
    })

    response.success? ? response['results'] : []
  end

    # Fetch watch providers (stream / rent / buy) for a movie
  def self.fetch_watch_providers(tmdb_id)
    response = get("/movie/#{tmdb_id}/watch/providers", query: {
      api_key: api_key
    })

    response.success? ? response['results'] : {}
  end
end
