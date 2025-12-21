class CreateWatchlistItems < ActiveRecord::Migration[7.1]
  def change
    create_table :watchlist_items do |t|
      t.references :movie, null: false, foreign_key: true, index: { unique: true }
      t.text :pitch
      t.timestamps
    end
  end
end