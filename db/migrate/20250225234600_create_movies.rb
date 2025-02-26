class CreateMovies < ActiveRecord::Migration[7.1]
  def change
    create_table :movies do |t|
      t.integer :tmdb_id
      t.string :title
      t.date :release_date
      t.string :poster_path

      t.timestamps
    end
  end
end
