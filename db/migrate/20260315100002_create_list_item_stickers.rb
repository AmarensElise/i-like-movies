class CreateListItemStickers < ActiveRecord::Migration[7.1]
  def change
    create_table :list_item_stickers do |t|
      t.bigint :list_item_id, null: false
      t.bigint :sticker_id,   null: false

      t.timestamps
    end

    add_index :list_item_stickers, [:list_item_id, :sticker_id], unique: true
    add_foreign_key :list_item_stickers, :list_items
    add_foreign_key :list_item_stickers, :stickers
  end
end
