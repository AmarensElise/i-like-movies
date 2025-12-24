class AddUserToFavoriteActors < ActiveRecord::Migration[7.1]
  def change
    add_reference :favorite_actors, :user, null: true, foreign_key: true

    add_index :favorite_actors, [:user_id, :actor_id], unique: true
  end
end
