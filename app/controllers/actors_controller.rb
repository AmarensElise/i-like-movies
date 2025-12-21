class ActorsController < ApplicationController
  def index
    @actors = Actor.where(favorite: true).order(:name)
  end

  def show
    @actor = Actor.find(params[:id])
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
