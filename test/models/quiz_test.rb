require "test_helper"

class QuizTest < ActiveSupport::TestCase
  test "start_for creates 10 questions" do
    user = users(:three)

    assert_difference ["Quiz.count", "QuizQuestion.count"], [1, 10] do
      quiz = Quiz.start_for(user)
      assert_equal "in_progress", quiz.status
      assert_equal 10, quiz.quiz_questions.count
      assert_equal (1..10).to_a, quiz.quiz_questions.pluck(:position)
    end
  end

  test "start_for reuses existing in progress quiz" do
    quiz = Quiz.start_for(users(:one))

    assert_equal quizzes(:in_progress_one), quiz
  end

  test "finalize sums points and marks quiz completed" do
    quiz = quizzes(:in_progress_one)
    quiz.quiz_questions.find_by(position: 10).update!(guessed_year: 2020, points_earned: 40, answered_at: Time.current)

    quiz.finalize!
    quiz.reload

    assert_equal 860, quiz.total_score
    assert_equal "completed", quiz.status
    assert_not_nil quiz.completed_at
  end

  test "finished returns true only when all 10 questions are answered" do
    assert_not quizzes(:in_progress_one).finished?
    assert quizzes(:completed_one).finished?
  end
end
