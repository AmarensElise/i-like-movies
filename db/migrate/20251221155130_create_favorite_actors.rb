class CreateFavoriteActors < ActiveRecord::Migration[7.1]
  def change
    create_table :favorite_actors do |t|
      t.references :actor, null: false, foreign_key: true, index: { unique: true }
      t.timestamps
    end
  end
end