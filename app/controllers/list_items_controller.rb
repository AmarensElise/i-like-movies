class ListItemsController < ApplicationController
  before_action :authenticate_user!

  def create
    @list = current_user.lists.find(params[:list_id])
    @movie = Movie.find(params[:movie_id])
    
    @list_item = @list.list_items.where(movie: @movie).first_or_create

    redirect_back fallback_location: @movie, notice: "Added to #{@list.name}"
  end

  def destroy
    @list_item = ListItem.joins(:list).where(lists: { user_id: current_user.id }).find(params[:id])
    list_name = @list_item.list.name
    @list_item.destroy
    
    redirect_back fallback_location: @list_item.movie, notice: "Removed from #{list_name}"
  end
end
