require "test_helper"

class QuizQuestionsControllerTest < ActionDispatch::IntegrationTest
  test "update submits guess and returns turbo stream" do
    sign_in users(:one)

    patch quiz_question_path(quizzes(:in_progress_one), quiz_questions(:in_progress_one_q10)),
          params: { quiz_question: { guessed_year: 2020 } },
          as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_includes response.body, "Actual year"

    question = quiz_questions(:in_progress_one_q10).reload
    assert_equal 2020, question.guessed_year
    assert_not_nil question.answered_at
    assert_equal "completed", quizzes(:in_progress_one).reload.status
  end

  test "update rejects unauthorized user" do
    sign_in users(:two)

    patch quiz_question_path(quizzes(:in_progress_one), quiz_questions(:in_progress_one_q10)),
          params: { quiz_question: { guessed_year: 2020 } },
          as: :turbo_stream

    assert_response :not_found
  end

  test "update rejects already answered question" do
    sign_in users(:one)

    patch quiz_question_path(quizzes(:in_progress_one), quiz_questions(:in_progress_one_q1)),
          params: { quiz_question: { guessed_year: 1991 } },
          as: :turbo_stream

    assert_response :unprocessable_entity
  end
end
