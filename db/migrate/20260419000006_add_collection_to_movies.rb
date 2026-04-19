class AddCollectionToMovies < ActiveRecord::Migration[7.1]
  def change
    add_column :movies, :tmdb_collection_id, :integer
    add_column :movies, :tmdb_collection_name, :string
    add_index :movies, :tmdb_collection_id
  end
end
