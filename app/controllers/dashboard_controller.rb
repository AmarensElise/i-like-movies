class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    @watchlist_count = current_user.watchlist_items.count
    @viewings_count = current_user.viewings.count
    @favorite_actors_count = current_user.favorite_actors.count
    @lists_count = current_user.lists.count
    @movie_likes_count = current_user.movie_likes.count
    @recent_lists = current_user.lists.order(updated_at: :desc).limit(3)
  end
end
