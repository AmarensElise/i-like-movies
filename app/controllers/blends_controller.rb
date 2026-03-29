  def new
    @blend = Blend.new
  end
class BlendsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie
  before_action :set_blend, only: [:destroy]

  def create
    @blend = @movie.blends.build(blend_params)
    @blend.user = current_user
    if @blend.save
      redirect_to @movie, notice: 'Blend was successfully created.'
    else
      redirect_to @movie, alert: @blend.errors.full_messages.to_sentence
    end
  end

  def destroy
    if @blend.user == current_user
      @blend.destroy
      redirect_to @movie, notice: 'Blend was successfully deleted.'
    else
      redirect_to @movie, alert: 'You can only delete your own blends.'
    end
  end

  private
    def set_movie
      @movie = Movie.friendly.find(params[:movie_id])
    end

    def set_blend
      @blend = @movie.blends.find(params[:id])
    end

    def blend_params
      params.require(:blend).permit(:ingredient1_id, :ingredient2_id, :hint_id)
    end
end
