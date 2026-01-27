class MovieLikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie_like, only: [:destroy]

  def create
    @movie = Movie.find(params[:movie_id])
    @movie_like = @movie.movie_likes.build(movie_like_params)
    @movie_like.user = current_user

    if @movie_like.save
      redirect_back fallback_location: @movie, notice: 'Thanks for sharing what you like!'
    else
      redirect_back fallback_location: @movie, alert: @movie_like.errors.full_messages.join(', ')
    end
  end

  def destroy
    if @movie_like.user == current_user
      @movie_like.destroy
      redirect_back fallback_location: @movie_like.movie, notice: 'Removed successfully'
    else
      redirect_back fallback_location: @movie_like.movie, alert: 'You can only delete your own likes'
    end
  end

  private

  def set_movie_like
    @movie_like = MovieLike.find(params[:id])
  end

  def movie_like_params
    params.require(:movie_like).permit(:content)
  end
end
