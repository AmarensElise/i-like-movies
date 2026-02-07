class ViewingsController < ApplicationController
  before_action :authenticate_user!

  def create
    movie = Movie.find(params[:movie_id])
    current_user.viewings.find_or_create_by!(movie: movie, watched_on: Date.today)

    # optional: auto-remove from watchlist
    current_user.watchlist_items.where(movie: movie).destroy_all

    redirect_back fallback_location: movie
  end

  def destroy
    viewing = current_user.viewings.find(params[:id])
    movie = viewing.movie
    viewing.destroy

    redirect_back fallback_location: movie
  end
end