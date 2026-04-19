require "test_helper"

class QuizzesControllerTest < ActionDispatch::IntegrationTest
  test "auth is required" do
    get new_quiz_path

    assert_redirected_to new_user_session_path
  end

  test "create starts a quiz" do
    sign_in users(:three)

    assert_difference ["Quiz.count", "QuizQuestion.count"], [1, 10] do
      post quizzes_path
    end

    assert_redirected_to quiz_path(Quiz.order(:id).last)
  end

  test "show renders in progress quiz" do
    sign_in users(:one)

    get quiz_path(quizzes(:in_progress_one))

    assert_response :success
    assert_includes response.body, "Question 10 of 10"
    assert_includes response.body, "Submit Guess"
  end

  test "show renders recap for completed quiz" do
    sign_in users(:one)

    get quiz_path(quizzes(:completed_one))

    assert_response :success
    assert_includes response.body, "Quiz Complete"
    assert_includes response.body, "View leaderboard"
  end

  test "cannot view another users quiz" do
    sign_in users(:one)

    get quiz_path(quizzes(:completed_two))

    assert_response :not_found
  end
end
