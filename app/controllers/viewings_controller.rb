class ViewingsController < ApplicationController
  def create
    movie = Movie.find(params[:movie_id])
    movie.viewings.find_or_create_by!(watched_on: Date.today)

    # optional: auto-remove from watchlist
    movie.watchlist_items.destroy_all

    redirect_back fallback_location: movie
  end
end