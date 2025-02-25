# config/initializers/themoviedb.rb
Tmdb::Api.key(ENV["TMDB_API_KEY"])
Tmdb::Api.language("en")
