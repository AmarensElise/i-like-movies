class AddDetailsToMovies < ActiveRecord::Migration[7.1]
  def change
    add_column :movies, :runtime, :integer
    add_column :movies, :genres, :string
  end
end
