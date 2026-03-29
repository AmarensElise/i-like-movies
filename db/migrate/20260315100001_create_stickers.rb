class CreateStickers < ActiveRecord::Migration[7.1]
  def change
    create_table :stickers do |t|
      t.string  :label,  null: false
      t.string  :color,  null: false
      t.boolean :preset, default: false, null: false
      t.bigint  :user_id

      t.timestamps
    end

    add_index :stickers, :preset
    add_index :stickers, :user_id
    add_foreign_key :stickers, :users
  end
end
