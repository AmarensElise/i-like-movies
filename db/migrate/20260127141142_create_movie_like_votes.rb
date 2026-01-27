class CreateMovieLikeVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :movie_like_votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :movie_like, null: false, foreign_key: true

      t.timestamps
    end
    add_index :movie_like_votes, [:user_id, :movie_like_id], unique: true
  end
end
