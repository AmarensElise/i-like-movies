class AddVoteAverageToMovies < ActiveRecord::Migration[7.1]
  def change
    add_column :movies, :vote_average, :decimal
  end
end
