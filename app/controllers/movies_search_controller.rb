class MoviesSearchController < ApplicationController
  def index
    query = params[:q].to_s.strip
    @movies = if query.length > 1
      Movie.where('title ILIKE ?', "%#{query}%").highest_grossing_first.limit(10)
    else
      []
    end
    render json: @movies.map { |m| { id: m.id, title: m.title } }
  end
end
