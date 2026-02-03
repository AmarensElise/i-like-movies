class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    @watchlist_count = current_user.watchlist_items.count
    @viewings_count = current_user.viewings.count
    @favorite_actors_count = current_user.favorite_actors.count
    @lists_count = current_user.lists.count
    @movie_likes_count = current_user.movie_likes.count
    @recent_lists = current_user.lists.order(updated_at: :desc).limit(3)
    
    # Recent viewings with movies
    @recent_viewings = current_user.viewings.includes(:movie).order(created_at: :desc).limit(6)
    
    # Recently added watchlist items
    @recent_watchlist = current_user.watchlist_items.includes(:movie).order(created_at: :desc).limit(6)
    
    # Favorite actors with their info from TMDB
    @favorite_actors = current_user.favorite_actors.includes(:actor).limit(6)
    # Fetch TMDB details for each actor
    @actor_details_map = {}
    @favorite_actors.each do |favorite_actor|
      actor = favorite_actor.actor
      @actor_details_map[actor.id] = TmdbService.fetch_person(actor.tmdb_id)
    end
    
    # Stats
    @total_movies_watched = current_user.viewings.distinct.count(:movie_id)
    @this_month_viewings = current_user.viewings.where('created_at >= ?', Time.current.beginning_of_month).count
    @this_week_viewings = current_user.viewings.where('created_at >= ?', Time.current.beginning_of_week).count
  end
end
