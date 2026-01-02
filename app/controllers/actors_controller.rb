class ActorsController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
    @actors = Actor.joins(:favorite_actors).where(favorite_actors: { user_id: current_user.id }).distinct
  end

  def show
    @actor = Actor.friendly.find(params[:id])
    @roles = @actor.roles.includes(:movie).order('movies.release_date DESC')

    # Fetch additional details from TMDB API
    begin
      @actor_details = TmdbService.fetch_person(@actor.tmdb_id)
    rescue => e
      Rails.logger.error("Error fetching actor details: #{e.message}")
      @actor_details = nil
    end
  end
end
