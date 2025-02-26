class MoviesController < ApplicationController
  def index
    popular_movies = Tmdb::Movie.popular

    # Handle different return types
    @popular_movies = if popular_movies.is_a?(Hash) && popular_movies['results']
                        popular_movies['results']
                      elsif popular_movies.respond_to?(:results)
                        popular_movies.results
                      elsif popular_movies.is_a?(Array)
                        popular_movies
                      else
                        []
                      end
  end

  def show
    tmdb_id = params[:id].to_i

    # Find or fetch movie details
    @movie = Movie.find_by(tmdb_id: tmdb_id)

    unless @movie
      # Fetch from API if not in our database
      movie_data = Tmdb::Movie.detail(tmdb_id)

      title = extract_value(movie_data, 'title')
      release_date = extract_value(movie_data, 'release_date')
      poster_path = extract_value(movie_data, 'poster_path')

      @movie = Movie.create(
        tmdb_id: tmdb_id,
        title: title,
        release_date: release_date,
        poster_path: poster_path
      )
    end

    # Get cast information
    credits = Tmdb::Movie.credits(tmdb_id)

    @cast = []

    # Extract cast list based on response type
    cast_list = if credits.is_a?(Hash) && credits['cast']
                  credits['cast']
                elsif credits.respond_to?(:cast)
                  credits.cast
                elsif credits.is_a?(Array)
                  credits
                else
                  []
                end

    cast_list.each do |cast_member|
      # Extract actor data
      actor_id = extract_value(cast_member, 'id')
      next unless actor_id # Skip if we can't get the actor ID

      actor_name = extract_value(cast_member, 'name')
      character = extract_value(cast_member, 'character')
      profile_path = extract_value(cast_member, 'profile_path')

      # Fetch actor details to get birthday
      begin
        actor_data = Tmdb::Person.detail(actor_id)
        birthday = extract_value(actor_data, 'birthday')
      rescue => e
        puts "Error fetching actor data: #{e.message}"
        birthday = nil
      end

      # Find or create actor
      actor = Actor.find_or_create_by(tmdb_id: actor_id) do |a|
        a.name = actor_name
        a.birthday = birthday
      end

      # Calculate age during filming if we have birthday and release date
      age_during_filming = nil
      if actor.birthday.present? && @movie.release_date.present?
        begin
          age_during_filming = ActorAgeCalculator.calculate(
            actor.birthday,
            Date.parse(@movie.release_date.to_s)
          )
        rescue => e
          puts "Error calculating age: #{e.message}"
        end
      end

      # Create or update role
      role = Role.find_or_create_by(
        movie: @movie,
        actor: actor
      ) do |r|
        r.character = character
        r.age_during_filming = age_during_filming
      end

      @cast << {
        actor: actor,
        character: character,
        age: age_during_filming,
        profile_path: profile_path
      }
    end
  end

  private

  # Helper method to extract values regardless of if it's a hash or object
  def extract_value(data, key)
    if data.is_a?(Hash)
      data[key] || data[key.to_sym]
    elsif data.respond_to?(key)
      data.send(key)
    else
      nil
    end
  end
end
