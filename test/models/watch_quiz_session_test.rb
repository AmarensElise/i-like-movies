require "test_helper"

class WatchQuizSessionTest < ActiveSupport::TestCase
  test "completed? returns true when completed_at is set" do
    session = watch_quiz_sessions(:completed_session)
    assert session.completed?
  end

  test "completed? returns false when completed_at is nil" do
    session = watch_quiz_sessions(:incomplete_session)
    assert_not session.completed?
  end

  test "persists answers as jsonb" do
    session = WatchQuizSession.create!(
      user: users(:one),
      answers: { "media_type" => "movie", "streaming" => "any" }
    )
    session.reload
    assert_equal "movie", session.answers["media_type"]
    assert_equal "any", session.answers["streaming"]
  end

  test "belongs to user" do
    session = watch_quiz_sessions(:completed_session)
    assert_equal users(:one), session.user
  end

  test "belongs to chosen_movie" do
    session = watch_quiz_sessions(:completed_session)
    assert_equal movies(:one), session.chosen_movie
  end

  test "belongs to rejected_movie" do
    session = watch_quiz_sessions(:completed_session)
    assert_equal movies(:two), session.rejected_movie
  end
end
