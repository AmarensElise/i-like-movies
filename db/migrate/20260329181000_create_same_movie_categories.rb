class CreateSameMovieCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :same_movie_categories do |t|
      t.references :user, null: false, foreign_key: true
      t.string :description, null: false
      t.timestamps
    end
  end
end
