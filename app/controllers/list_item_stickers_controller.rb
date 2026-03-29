class ListItemStickersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list_and_list_item

  def create
    @sticker = find_available_sticker(params[:sticker_id])
    @list_item_sticker = @list_item.list_item_stickers.build(sticker: @sticker)

    if @list_item_sticker.save
      respond_to do |format|
        format.turbo_stream {
          @available_stickers = Sticker.presets + Sticker.custom_for(current_user)
        }
        format.html { redirect_to list_path(@list), notice: "Sticker added." }
      end
    else
      redirect_to list_path(@list), alert: "Could not add sticker."
    end
  end

  def destroy
    @list_item_sticker = @list_item.list_item_stickers.find(params[:id])
    @sticker = @list_item_sticker.sticker
    @list_item_sticker.destroy

    respond_to do |format|
      format.turbo_stream {
        @available_stickers = Sticker.presets + Sticker.custom_for(current_user)
      }
      format.html { redirect_to list_path(@list), notice: "Sticker removed." }
    end
  end

  private

  def set_list_and_list_item
    @list = current_user.lists.find(params[:list_id])
    @list_item = @list.list_items.find(params[:list_item_id])
  end

  def find_available_sticker(sticker_id)
    # Users can apply preset stickers or their own custom stickers
    Sticker.where(id: sticker_id)
           .where("preset = ? OR user_id = ?", true, current_user.id)
           .first!
  end
end
