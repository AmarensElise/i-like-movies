class CreateShows < ActiveRecord::Migration[7.1]
  def change
    create_table :shows do |t|
      t.integer :tmdb_id
      t.string :name
      t.date :first_air_date
      t.date :last_air_date
      t.string :poster_path
      t.decimal :vote_average
      t.string :genres
      t.string :slug

      t.timestamps
    end
    add_index :shows, :tmdb_id, unique: true
    add_index :shows, :slug, unique: true
  end
end
