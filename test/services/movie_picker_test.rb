require "test_helper"

class MoviePickerTest < ActiveSupport::TestCase
  setup do
    @user = users(:two) # no viewings
  end

  test "call excludes seen movies" do
    user_with_viewings = users(:one) # has viewings for one, two
    picker = MoviePicker.new(user: user_with_viewings, filters: { streaming: "any", length: "any", adventurousness: "no_bias" })
    ids = picker.call.pluck(:id)
    assert_not_includes ids, movies(:one).id
    assert_not_includes ids, movies(:two).id
  end

  test "call with under_90 filter returns short movies" do
    picker = MoviePicker.new(user: @user, filters: { streaming: "any", length: "under_90", adventurousness: "no_bias" })
    ids = picker.call.pluck(:id)
    assert_includes ids, movies(:two).id   # 85 min
    assert_not_includes ids, movies(:one).id # 120 min
  end

  test "call with over_90 filter returns long movies" do
    picker = MoviePicker.new(user: @user, filters: { streaming: "any", length: "over_90", adventurousness: "no_bias" })
    ids = picker.call.pluck(:id)
    assert_includes ids, movies(:one).id   # 120 min
    assert_not_includes ids, movies(:two).id # 85 min
  end

  test "call with decade filter scopes correctly" do
    picker = MoviePicker.new(user: @user, filters: { streaming: "any", length: "any", adventurousness: "no_bias", decade: 1990 })
    ids = picker.call.pluck(:id)
    assert_includes ids, movies(:one).id   # 1991
    assert_includes ids, movies(:two).id   # 1994
    assert_not_includes ids, movies(:four).id  # 2001 (also excluded by orphan rule)
  end

  test "call with collection none filter returns standalones" do
    picker = MoviePicker.new(user: @user, filters: { streaming: "any", length: "any", adventurousness: "no_bias", collection: "none" })
    ids = picker.call.pluck(:id)
    assert_includes ids, movies(:one).id
    assert_not_includes ids, movies(:three).id # has collection
  end

  test "call_without_streaming skips streaming filter" do
    picker = MoviePicker.new(user: @user, filters: { streaming: "domestic", length: "any", adventurousness: "no_bias" })
    # call_without_streaming should return results regardless of streaming
    ids = picker.call_without_streaming.pluck(:id)
    assert ids.any?
  end

  test "call excludes orphan sequels" do
    picker = MoviePicker.new(user: @user, filters: { streaming: "any", length: "any", adventurousness: "no_bias" })
    ids = picker.call.pluck(:id)
    # four is sequel in collection 100, user hasn't seen three
    assert_not_includes ids, movies(:four).id
    # three is the earliest in collection — included
    assert_includes ids, movies(:three).id
  end
end
