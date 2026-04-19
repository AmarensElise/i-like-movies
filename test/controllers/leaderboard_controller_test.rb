require "test_helper"

class LeaderboardControllerTest < ActionDispatch::IntegrationTest
  test "leaderboard respects threshold and ordering" do
    sign_in users(:one)

    2.times { create_completed_quiz_for(users(:one), guess_offset: 0) }
    2.times { create_completed_quiz_for(users(:two), guess_offset: 5) }
    2.times { create_completed_quiz_for(users(:three), guess_offset: 0) }

    get leaderboard_path

    assert_response :success
    assert_includes response.body, users(:one).username
    assert_includes response.body, users(:two).username
    assert_not_includes response.body, users(:three).username
    assert_operator response.body.index(users(:one).username), :<, response.body.index(users(:two).username)
  end

  private

  def create_completed_quiz_for(user, guess_offset:)
    quiz = user.quizzes.create!(status: "in_progress", started_at: Time.current)

    Movie.quiz_eligible.limit(10).each.with_index(1) do |movie, position|
      guessed_year = movie.release_year + guess_offset
      points = guess_offset.abs

      quiz.quiz_questions.create!(
        movie: movie,
        position: position,
        guessed_year: guessed_year,
        points_earned: points,
        answered_at: Time.current
      )
    end

    quiz.finalize!
  end
end
