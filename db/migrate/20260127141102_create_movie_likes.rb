class CreateMovieLikes < ActiveRecord::Migration[7.1]
  def change
    create_table :movie_likes do |t|
      t.text :content, null: false
      t.references :user, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true

      t.timestamps
    end
    add_index :movie_likes, [:movie_id, :created_at]
  end
end
