class FavoriteActorsController < ApplicationController
  def create
    actor = Actor.find(params[:actor_id])

    actor.favorite_actors.first_or_create!

    ActorFilmographyImporter.new(actor).import!

    redirect_back fallback_location: actor
  end

  def destroy
    favorite = FavoriteActor.find(params[:id])
    actor = favorite.actor

    favorite.destroy

    redirect_back fallback_location: actor
  end
end
