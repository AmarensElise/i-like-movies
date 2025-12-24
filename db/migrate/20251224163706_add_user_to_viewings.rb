class AddUserToViewings < ActiveRecord::Migration[7.1]
  def change
    add_reference :viewings, :user, null: true, foreign_key: true

    # Optional: prevent duplicate "seen" records per user/movie.
    add_index :viewings, [:user_id, :movie_id], unique: true
  end
end
