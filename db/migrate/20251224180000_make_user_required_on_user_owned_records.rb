class MakeUserRequiredOnUserOwnedRecords < ActiveRecord::Migration[7.1]
  def change
    change_column_null :watchlist_items, :user_id, false
    change_column_null :viewings, :user_id, false
    change_column_null :favorite_actors, :user_id, false

    # The original migration created a global unique index on actor_id.
    # With per-user favorites, actor_id alone should not be unique.
    remove_index :favorite_actors, :actor_id if index_exists?(:favorite_actors, :actor_id)
  end
end
