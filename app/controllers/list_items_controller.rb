class ListItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list
  before_action :set_list_item, only: [:show, :update, :destroy]

  def show
    @available_stickers = Sticker.presets + Sticker.custom_for(current_user)

    respond_to do |format|
      format.html { render partial: "list_items/list_item_detail", locals: { list_item: @list_item, list: @list, available_stickers: @available_stickers } }
    end
  end

  def create
    @movie = Movie.find(params[:movie_id])
    @list_item = @list.list_items.where(movie: @movie).first_or_initialize
    @list_item.position ||= @list.list_items.maximum(:position).to_i + 1

    if @list_item.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: list_path(@list), notice: "Added to #{@list.name}" }
      end
    else
      redirect_back fallback_location: list_path(@list), alert: "Could not add movie."
    end
  end

  def update
    if @list_item.update(list_item_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to list_path(@list), notice: "Updated." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@list_item, partial: "list_items/list_item_detail", locals: { list_item: @list_item, list: @list }) }
        format.html { redirect_to list_path(@list), alert: "Could not update." }
      end
    end
  end

  def destroy
    @list_item.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to list_path(@list), notice: "Removed from #{@list.name}" }
    end
  end

  private

  def set_list
    @list = current_user.lists.find(params[:list_id])
  end

  def set_list_item
    @list_item = @list.list_items.find(params[:id])
  end

  def list_item_params
    params.require(:list_item).permit(:rating, :note, :position)
  end
end
