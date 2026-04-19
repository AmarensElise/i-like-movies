class CreateQuizQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :quiz_questions do |t|
      t.references :quiz, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true
      t.integer :position, null: false
      t.integer :guessed_year
      t.integer :points_earned
      t.datetime :answered_at

      t.timestamps
    end

    add_index :quiz_questions, [:quiz_id, :position], unique: true
    add_index :quiz_questions, [:quiz_id, :movie_id], unique: true
  end
end
