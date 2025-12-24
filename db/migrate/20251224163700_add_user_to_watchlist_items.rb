class AddUserToWatchlistItems < ActiveRecord::Migration[7.1]
  def change
    add_reference :watchlist_items, :user, null: true, foreign_key: true

    # If you previously had a unique index on movie_id, you likely want
    # uniqueness per-user now.
    if index_exists?(:watchlist_items, :movie_id, unique: true)
      remove_index :watchlist_items, :movie_id
    end

    add_index :watchlist_items, [:user_id, :movie_id], unique: true
  end
end
