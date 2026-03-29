class CreateBlends < ActiveRecord::Migration[7.1]
  def change
    create_table :blends do |t|
      t.references :movie, null: false, foreign_key: true
      t.integer :ingredient1_id
      t.integer :ingredient2_id
      t.integer :hint_id
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
