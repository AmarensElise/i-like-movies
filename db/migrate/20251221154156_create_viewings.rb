class CreateViewings < ActiveRecord::Migration[7.1]
  def change
    create_table :viewings do |t|
      t.references :movie, null: false, foreign_key: true
      t.date :watched_on
      t.timestamps
    end
  end
end