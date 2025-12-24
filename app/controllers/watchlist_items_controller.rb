class WatchlistItemsController < ApplicationController
  before_action :authenticate_user!

  def create
    # Support both legacy requests that send movie_id at top-level and the
    # form_with which sends watchlist_item[...] params (including :pitch).
    if params[:watchlist_item].present?
      item_params = params.require(:watchlist_item).permit(:movie_id, :pitch)
      movie = Movie.find(item_params[:movie_id])
      item = current_user.watchlist_items.where(movie: movie).first_or_initialize
      # Only set pitch when provided (allow empty/omitted)
      item.pitch = item_params[:pitch] if item_params.key?(:pitch)
      item.save!
    elsif params[:movie_id].present?
      movie = Movie.find(params[:movie_id])
      current_user.watchlist_items.where(movie: movie).first_or_create!
    else
      # Nothing sensible to do
      redirect_back fallback_location: movies_path and return
    end

    redirect_back fallback_location: movie
  end

  def destroy
    item = current_user.watchlist_items.find(params[:id])
    item.destroy
    redirect_back fallback_location: item.movie
  end
end