class CreateActors < ActiveRecord::Migration[7.1]
  def change
    create_table :actors do |t|
      t.integer :tmdb_id
      t.string :name
      t.date :birthday

      t.timestamps
    end
  end
end
