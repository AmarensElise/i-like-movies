require "test_helper"

class Watch::QuizControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "show redirects to streaming step" do
    get watch_quiz_path
    assert_redirected_to streaming_watch_quiz_path
  end

  test "streaming step renders" do
    get streaming_watch_quiz_path
    assert_response :success
    assert_select "h1", /stream/i
  end

  test "length step renders" do
    get length_watch_quiz_path(streaming: "any")
    assert_response :success
    assert_select "h1", /long/i
  end

  test "adventurousness step renders" do
    get adventurousness_watch_quiz_path(streaming: "any", length: "any")
    assert_response :success
    assert_select "h1", /adventurous/i
  end

  test "category step renders" do
    get category_watch_quiz_path(streaming: "any", length: "any", adventurousness: "no_bias")
    assert_response :success
    assert_select "h1", /category/i
  end

  test "final step renders" do
    get final_watch_quiz_path(
      streaming: "any",
      length: "any",
      adventurousness: "no_bias",
      category_key: "standalones",
      category_label: "Just a standalone"
    )
    assert_response :success
  end

  test "complete creates session and redirects to completed page" do
    movie = movies(:three)
    other = movies(:five)

    assert_difference "WatchQuizSession.count", 1 do
      post complete_watch_quiz_path, params: {
        streaming: "any",
        length: "any",
        adventurousness: "no_bias",
        category_key: "standalones",
        category_label: "Just a standalone",
        chosen_movie_id: movie.id,
        rejected_movie_id: other.id
      }
    end

    session = WatchQuizSession.last
    assert_equal @user.id, session.user_id
    assert_equal movie.id, session.chosen_movie_id
    assert_equal other.id, session.rejected_movie_id
    assert session.completed?
    assert_equal "any", session.answers["streaming"]
    assert_equal "any", session.answers["length"]
    assert_equal "no_bias", session.answers["adventurousness"]
    assert_equal({ "key" => "standalones", "label" => "Just a standalone" }, session.answers["category"])
    assert_redirected_to completed_watch_quiz_path(session_id: session.id)
  end

  test "completed page renders movie details" do
    session = WatchQuizSession.create!(
      user: @user,
      chosen_movie: movies(:three),
      rejected_movie: movies(:four),
      answers: { "media_type" => "movie" },
      completed_at: Time.current
    )

    get completed_watch_quiz_path(session_id: session.id)
    assert_response :success
    assert_select "h1", text: /#{Regexp.escape(movies(:three).title)}/
    assert_select "p", text: /Duration/
    assert_select "p", text: /Starring/
  end

  test "unauthenticated user is redirected" do
    sign_out @user
    get streaming_watch_quiz_path
    assert_redirected_to new_user_session_path
  end
end
