class CreateShowRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :show_roles do |t|
      t.references :show, null: false, foreign_key: true
      t.references :actor, null: false, foreign_key: true
      t.string :character

      t.timestamps
    end

    add_index :show_roles, [:show_id, :actor_id], unique: true
  end
end
