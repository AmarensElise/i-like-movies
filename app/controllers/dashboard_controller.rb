class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    @watchlist_count = current_user.watchlist_items.count
    @viewings_count = current_user.viewings.count
    @favorite_actors_count = current_user.favorite_actors.count
  end
end
