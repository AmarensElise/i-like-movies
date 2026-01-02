class AddSlugToActors < ActiveRecord::Migration[7.1]
  def change
    add_column :actors, :slug, :string
    add_index :actors, :slug, unique: true
  end
end
