class CreateQuizzes < ActiveRecord::Migration[7.1]
  def change
    create_table :quizzes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, default: 'in_progress'
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :total_score, default: 0

      t.timestamps
    end

    add_index :quizzes, [:user_id, :status]
  end
end
