class WatchlistItemsController < ApplicationController
  def create
    movie = Movie.find(params[:movie_id])
    movie.watchlist_items.first_or_create!
    redirect_back fallback_location: movie
  end

  def destroy
    item = WatchlistItem.find(params[:id])
    item.destroy
    redirect_back fallback_location: item.movie
  end
end