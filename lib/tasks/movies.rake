namespace :movies do
  desc "Fetch trending movies from TMDB and populate database"
  task fetch_trending: :environment do
    puts "Fetching trending movies from TMDB..."
    fetch_movies_from_tmdb('trending')
  end

  desc "Fetch top rated movies from TMDB and populate database"
  task fetch_top_rated: :environment do
    puts "Fetching top rated movies from TMDB..."
    fetch_movies_from_tmdb('top_rated')
  end

  desc "Fetch now playing movies from TMDB and populate database"
  task fetch_now_playing: :environment do
    puts "Fetching now playing movies from TMDB..."
    fetch_movies_from_tmdb('now_playing')
  end

  desc "Fetch upcoming movies from TMDB and populate database"
  task fetch_upcoming: :environment do
    puts "Fetching upcoming movies from TMDB..."
    fetch_movies_from_tmdb('upcoming')
  end

  desc "Fetch movies by genre from TMDB and populate database"
  task :fetch_by_genre, [:genre_id] => :environment do |t, args|
    genre_id = args[:genre_id] || 28  # Default to Action (genre_id 28) if not specified
    puts "Fetching movies from genre ID #{genre_id}..."
    fetch_movies_from_tmdb('genre', genre_id)
  end

  desc "Fetch movies by year from TMDB and populate database"
  task :fetch_by_year, [:year] => :environment do |t, args|
    year = args[:year] || Date.today.year
    puts "Fetching movies from year #{year}..."
    fetch_movies_from_tmdb('year', year)
  end

  desc "Fetch movies for a specific actor by TMDB actor ID"
  task :fetch_actor_movies, [:actor_id] => :environment do |t, args|
    actor_id = args[:actor_id]
    if actor_id.present?
      puts "Fetching movies for actor ID #{actor_id}..."
      fetch_movies_from_tmdb('actor', actor_id)
    else
      puts "Please provide an actor ID: rake movies:fetch_actor_movies[12345]"
    end
  end

  desc "Fetch all movie types at once (trending, top rated, now playing, upcoming)"
  task fetch_all: [:fetch_trending, :fetch_top_rated, :fetch_now_playing, :fetch_upcoming] do
    puts "Completed fetching all movie types!"
  end

  desc "Fetch movies by keyword search"
  task :fetch_by_keyword, [:keyword] => :environment do |t, args|
    keyword = args[:keyword]
    if keyword.present?
      puts "Fetching movies matching keyword '#{keyword}'..."
      fetch_movies_from_tmdb('keyword', keyword)
    else
      puts "Please provide a keyword: rake movies:fetch_by_keyword[action]"
    end
  end

  # Helper method to fetch and process movies from TMDB
  def fetch_movies_from_tmdb(fetch_type, parameter = nil)
    # Determine which API endpoint to call based on the fetch type
    movies_data = case fetch_type
                  when 'trending'
                    TmdbService.trending_movies('week')
                  when 'top_rated'
                    TmdbService.top_rated_movies
                  when 'now_playing'
                    TmdbService.now_playing_movies
                  when 'upcoming'
                    TmdbService.upcoming_movies
                  when 'genre'
                    TmdbService.movies_by_genre(parameter)
                  when 'year'
                    TmdbService.movies_by_year(parameter)
                  when 'actor'
                    TmdbService.movies_by_actor(parameter)
                  when 'keyword'
                    TmdbService.search_movies(parameter)
                  else
                    puts "Unknown fetch type: #{fetch_type}"
                    return []
                  end

    # Process the movies
    process_movie_data(movies_data)
  end

  # Process movie data and save to database
  def process_movie_data(movies_data)
    count = 0

    movies_data.each do |movie_data|
      # Skip movies without a title or release date
      next if movie_data['title'].blank? || movie_data['release_date'].blank?

      # Check if movie already exists in database
      movie = Movie.find_by(tmdb_id: movie_data['id'])

      if movie.nil?
        puts "Adding new movie: #{movie_data['title']}"

        # Create movie record
        movie = Movie.create!(
          tmdb_id: movie_data['id'],
          title: movie_data['title'],
          release_date: movie_data['release_date'],
          poster_path: movie_data['poster_path']
        )

        # Fetch and add cast information
        cast_data = TmdbService.fetch_movie_credits(movie.tmdb_id)

        cast_data['cast'].first(10).each do |cast_member|
          # Skip cast members without a name
          next if cast_member['name'].blank?

          # Find or create actor
          actor = Actor.find_by(tmdb_id: cast_member['id'])

          if actor.nil?
            actor_details = TmdbService.fetch_person(cast_member['id'])

            actor = Actor.create!(
              tmdb_id: cast_member['id'],
              name: cast_member['name'],
              birthday: actor_details['birthday']
            )
          end

          # Create role
          unless Role.exists?(movie: movie, actor: actor)
            release_date = movie.release_date
            birthday = actor.birthday

            age_during_filming = nil
            if birthday.present? && release_date.present?
              release_year = release_date.year
              birthday_year = birthday.year

              age = release_year - birthday_year

              # Adjust for month and day
              if release_date.month < birthday.month ||
                (release_date.month == birthday.month && release_date.day < birthday.day)
                age -= 1
              end

              age_during_filming = age
            end

            Role.create!(
              movie: movie,
              actor: actor,
              character: cast_member['character'],
              age_during_filming: age_during_filming
            )
          end
        end

        count += 1
      else
        puts "Movie already exists: #{movie_data['title']}"
      end
    end

    puts "Added #{count} new movies to the database."
  end
end
