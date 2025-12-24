class FavoriteActorsController < ApplicationController
  before_action :authenticate_user!

  def create
    actor = Actor.find(params[:actor_id])

    current_user.favorite_actors.where(actor: actor).first_or_create!

    ActorFilmographyImporter.new(actor).import!

    redirect_back fallback_location: actor
  end

  def destroy
    favorite = current_user.favorite_actors.find(params[:id])
    actor = favorite.actor

    favorite.destroy

    redirect_back fallback_location: actor
  end
end
