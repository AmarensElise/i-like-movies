class LeaderboardController < ApplicationController
  def show
    stats = User
      .joins(quizzes: :quiz_questions)
      .joins("INNER JOIN movies ON movies.id = quiz_questions.movie_id")
      .where(quizzes: { status: "completed" })
      .group("users.id")
      .having("COUNT(DISTINCT quizzes.id) >= 3")
      .select(
        "users.id",
        "users.username",
        "COUNT(DISTINCT quizzes.id) AS quizzes_count",
        "AVG(ABS(quiz_questions.guessed_year - EXTRACT(YEAR FROM movies.release_date))) AS avg_years_off",
        "SUM(CASE WHEN quiz_questions.points_earned = 0 THEN 1 ELSE 0 END) AS exact_guesses",
        "MIN(quizzes.total_score) AS best_score"
      )

    ranked = User
      .from("(#{stats.to_sql}) leaderboard_entries")
      .select(
        "leaderboard_entries.*",
        "RANK() OVER (ORDER BY avg_years_off ASC, quizzes_count DESC, username ASC) AS rank"
      )

    @entries = User
      .from("(#{ranked.to_sql}) ranked_entries")
      .select("ranked_entries.*")
      .order("rank ASC")
      .limit(50)

    return unless user_signed_in?

    @current_user_entry = User
      .from("(#{ranked.to_sql}) ranked_entries")
      .select("ranked_entries.*")
      .where("ranked_entries.id = ?", current_user.id)
      .take
  end
end
