class AddShelfFieldsToListItems < ActiveRecord::Migration[7.1]
  def change
    add_column :list_items, :position, :integer
    add_column :list_items, :note, :text
    add_column :list_items, :rating, :integer
  end
end
