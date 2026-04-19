require "test_helper"

class QuizQuestionTest < ActiveSupport::TestCase
  test "submit_guess computes exact score" do
    question = build_question_for_year(1991)

    question.submit_guess!(1991)

    assert_equal 0, question.points_earned
  end

  test "submit_guess computes off by one score" do
    question = build_question_for_year(1991)

    question.submit_guess!(1992)

    assert_equal 1, question.points_earned
  end

  test "submit_guess returns absolute years off when far off" do
    question = build_question_for_year(1991)

    question.submit_guess!(2006)

    assert_equal 15, question.points_earned
  end

  test "submit_guess accepts boundary years" do
    old_question = build_question_for_year(1900)
    new_question = build_question_for_year(Date.current.year)

    old_question.submit_guess!(1900)
    new_question.submit_guess!(Date.current.year)

    assert_equal 0, old_question.points_earned
    assert_equal 0, new_question.points_earned
  end

  test "submit_guess raises when already answered" do
    question = build_question_for_year(1991)
    question.submit_guess!(1991)

    assert_raises(RuntimeError) do
      question.submit_guess!(1992)
    end
  end

  private

  def build_question_for_year(year)
    user = users(:three)
    quiz = user.quizzes.create!(status: "in_progress", started_at: Time.current)
    movie = Movie.create!(tmdb_id: 10_000 + year, title: "Movie #{year}", release_date: Date.new(year, 1, 1))

    quiz.quiz_questions.create!(movie: movie, position: quiz.quiz_questions.count + 1)
  end
end
