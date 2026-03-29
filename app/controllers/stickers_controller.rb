class StickersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sticker, only: [:update, :destroy]

  def create
    @sticker = current_user.stickers.build(sticker_params)
    @sticker.preset = false

    if @sticker.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: lists_path, notice: "Sticker created." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_sticker_form", partial: "stickers/form", locals: { sticker: @sticker }) }
        format.html { redirect_back fallback_location: lists_path, alert: @sticker.errors.full_messages.join(", ") }
      end
    end
  end

  def update
    if @sticker.update(sticker_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: lists_path, notice: "Sticker updated." }
      end
    else
      redirect_back fallback_location: lists_path, alert: @sticker.errors.full_messages.join(", ")
    end
  end

  def destroy
    @sticker.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: lists_path, notice: "Sticker deleted." }
    end
  end

  private

  def set_sticker
    @sticker = current_user.stickers.find(params[:id])
  end

  def sticker_params
    params.require(:sticker).permit(:label, :color)
  end
end
