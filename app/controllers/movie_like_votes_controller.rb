class MovieLikeVotesController < ApplicationController
  before_action :authenticate_user!

  def create
    @movie_like = MovieLike.find(params[:movie_like_id])
    @vote = @movie_like.movie_like_votes.where(user: current_user).first_or_initialize

    if @vote.new_record?
      @vote.save
      redirect_back fallback_location: @movie_like.movie, notice: 'Agreed!'
    else
      redirect_back fallback_location: @movie_like.movie, notice: 'You already agreed with this'
    end
  end

  def destroy
    @vote = current_user.movie_like_votes.find(params[:id])
    @movie = @vote.movie_like.movie
    @vote.destroy
    redirect_back fallback_location: @movie, notice: 'Removed your agreement'
  end
end
