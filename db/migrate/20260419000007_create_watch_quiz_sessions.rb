class CreateWatchQuizSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :watch_quiz_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.jsonb :answers, default: {}
      t.references :chosen_movie, foreign_key: { to_table: :movies }
      t.references :rejected_movie, foreign_key: { to_table: :movies }
      t.datetime :completed_at

      t.timestamps
    end
  end
end
