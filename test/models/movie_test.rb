require "test_helper"

class MovieTest < ActiveSupport::TestCase
  test "quiz_eligible excludes movies without release date" do
    eligible_ids = Movie.quiz_eligible.pluck(:id)

    assert_includes eligible_ids, movies(:one).id
    assert_includes eligible_ids, movies(:ten).id
    assert_not_includes eligible_ids, movies(:missing_release).id
  end

  test "quiz_eligible excludes documentaries" do
    eligible_ids = Movie.quiz_eligible.pluck(:id)

    assert_not_includes eligible_ids, movies(:documentary_movie).id
  end

  test "quiz_eligible excludes movies with no genres" do
    eligible_ids = Movie.quiz_eligible.pluck(:id)

    assert_not_includes eligible_ids, movies(:no_genre_movie).id
  end

  test "quiz_eligible excludes behind-the-scenes entries" do
    eligible_ids = Movie.quiz_eligible.pluck(:id)

    assert_not_includes eligible_ids, movies(:behind_scenes_movie).id
  end

  test "random_popular limits to requested eligible movies" do
    selected_ids = Movie.random_popular(5).pluck(:id)

    assert_equal 5, selected_ids.size
    assert_empty selected_ids - Movie.quiz_eligible.pluck(:id)
    assert_match "GREATEST", Movie.random_popular(5).to_sql
  end

  test "release_year returns release date year" do
    assert_equal 1991, movies(:one).release_year
    assert_nil movies(:missing_release).release_year
  end

  # -- Watch Quiz scopes --

  test "under_90 returns movies with runtime under 90" do
    ids = Movie.under_90.pluck(:id)
    assert_includes ids, movies(:two).id   # runtime 85
    assert_includes ids, movies(:five).id  # runtime 80
    assert_not_includes ids, movies(:one).id # runtime 120
  end

  test "at_least_90 returns movies with runtime 90 or above" do
    ids = Movie.at_least_90.pluck(:id)
    assert_includes ids, movies(:one).id    # runtime 120
    assert_includes ids, movies(:three).id  # runtime 95
    assert_not_includes ids, movies(:two).id # runtime 85
  end

  test "released_in_decade scopes to the correct decade" do
    ids = Movie.released_in_decade(1990).pluck(:id)
    assert_includes ids, movies(:one).id   # 1991
    assert_includes ids, movies(:two).id   # 1994
    assert_not_includes ids, movies(:three).id # 1987
    assert_not_includes ids, movies(:four).id  # 2001
  end

  test "standalones returns movies without a collection" do
    ids = Movie.standalones.pluck(:id)
    assert_includes ids, movies(:one).id
    assert_not_includes ids, movies(:three).id # has collection 100
  end

  test "in_a_collection returns movies with a collection" do
    ids = Movie.in_a_collection.pluck(:id)
    assert_includes ids, movies(:three).id
    assert_includes ids, movies(:four).id
    assert_not_includes ids, movies(:one).id
  end

  test "without_orphan_sequels_for excludes sequel when prior unseen" do
    user = users(:two) # user two has no viewings
    ids = Movie.without_orphan_sequels_for(user).pluck(:id)
    # three (1987) is earliest in collection 100 — should be included
    assert_includes ids, movies(:three).id
    # four (2001) is a sequel in collection 100 — user hasn't seen three — excluded
    assert_not_includes ids, movies(:four).id
    # standalone movies always included
    assert_includes ids, movies(:one).id
  end

  test "without_orphan_sequels_for includes sequel when prior is seen" do
    user = users(:one) # we'll add a viewing for movie three
    Viewing.find_or_create_by!(user: user, movie: movies(:three), watched_on: Date.current)
    ids = Movie.without_orphan_sequels_for(user).pluck(:id)
    # Now user has seen three, so four should be included
    assert_includes ids, movies(:four).id
  end

  test "without_orphan_sequels_for includes sequel on watchlist" do
    user = users(:two) # no viewings
    WatchlistItem.create!(user: user, movie: movies(:four))
    ids = Movie.without_orphan_sequels_for(user).pluck(:id)
    # four is on the watchlist, so it should be included despite prior unseen
    assert_includes ids, movies(:four).id
  end

  test "unseen_by returns movies the user has not watched" do
    user = users(:one) # has viewings for movies one and two
    ids = Movie.unseen_by(user).pluck(:id)
    assert_not_includes ids, movies(:one).id
    assert_not_includes ids, movies(:two).id
    assert_includes ids, movies(:three).id
  end

  # -- pitch_line --

  test "pitch_line with age formats correctly" do
    movie = movies(:one)
    user = users(:one)
    # role one: actor one, age_during_filming: 1 (< 15)
    line = movie.pitch_line(user: user)
    # age < 15, so it should say "starring" instead
    assert_match(/starring/i, line)
  end

  test "pitch_line prefers favorite actor" do
    movie = movies(:one)
    user = users(:one) # has favorite_actors: one
    role = roles(:one) # actor one for movie one
    role.update!(age_during_filming: 30)
    line = movie.pitch_line(user: user)
    assert_match(/30-year-old/, line)
    assert_match actors(:one).name, line
  end

  test "pitch_line returns title when no roles exist" do
    movie = movies(:five) # no roles defined in fixtures
    user = users(:two)
    assert_equal movie.title, movie.pitch_line(user: user)
  end
end
