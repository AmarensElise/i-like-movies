class MakeUserRequiredOnUserOwnedRecords < ActiveRecord::Migration[7.1]
  def change
    backfill_user_ids!

    change_column_null :watchlist_items, :user_id, false
    change_column_null :viewings, :user_id, false
    change_column_null :favorite_actors, :user_id, false

    # The original migration created a global unique index on actor_id.
    # With per-user favorites, actor_id alone should not be unique.
    remove_index :favorite_actors, :actor_id if index_exists?(:favorite_actors, :actor_id)
  end

  private

  # Production may already have watchlist/viewing/favorite rows created before user scoping.
  # To safely enforce NOT NULL, we assign those legacy rows to a dedicated "legacy@moviedb.local" user.
  def backfill_user_ids!
    return unless column_exists?(:watchlist_items, :user_id)

    # A valid bcrypt hash for the string 'changeme' (so Devise validations are satisfied).
    # This user isn't meant to be used interactively.
    encrypted_password = "$2a$12$C.0wD8iT7h6l8nZr7sVg1eQK4w2mXl0hJgq5n0gKQ1X2o2pOeQ2xS"

    legacy_user_id = select_value(<<~SQL)
      INSERT INTO users (email, encrypted_password, created_at, updated_at)
      VALUES ('legacy@moviedb.local', '#{encrypted_password}', NOW(), NOW())
      ON CONFLICT (email) DO UPDATE SET updated_at = EXCLUDED.updated_at
      RETURNING id
    SQL

    execute("UPDATE watchlist_items SET user_id = #{legacy_user_id} WHERE user_id IS NULL")
    execute("UPDATE viewings SET user_id = #{legacy_user_id} WHERE user_id IS NULL")
    execute("UPDATE favorite_actors SET user_id = #{legacy_user_id} WHERE user_id IS NULL")
  end
end
