require "test_helper"

class CategorySuggesterTest < ActiveSupport::TestCase
  setup do
    @user = users(:two) # no viewings
    @base_filters = { streaming: "any", length: "any", adventurousness: "no_bias" }
  end

  test "returns up to count categories" do
    categories = CategorySuggester.new(user: @user, base_filters: @base_filters, seed: "test123").call
    assert categories.size <= CategorySuggester::DEFAULT_COUNT
  end

  test "drops templates with too few matches" do
    # With count: 10 and the small fixture set, some templates won't have 5+ movies
    categories = CategorySuggester.new(user: @user, base_filters: @base_filters, count: 10, seed: "test").call
    categories.each do |cat|
      pool = MoviePicker.new(
        user: @user,
        filters: @base_filters.merge(cat[:filters])
      ).call_without_streaming.count
      assert pool >= CategorySuggester::MIN_POOL_SIZE,
             "Category #{cat[:key]} has only #{pool} movies, expected >= #{CategorySuggester::MIN_POOL_SIZE}"
    end
  end

  test "deterministic given a seed" do
    a = CategorySuggester.new(user: @user, base_filters: @base_filters, seed: "fixed_seed").call
    b = CategorySuggester.new(user: @user, base_filters: @base_filters, seed: "fixed_seed").call
    assert_equal a.map { |c| c[:key] }, b.map { |c| c[:key] }
  end

  test "each category has key, label, and filters" do
    categories = CategorySuggester.new(user: @user, base_filters: @base_filters, seed: "abc").call
    categories.each do |cat|
      assert cat[:key].present?, "Category missing key"
      assert cat[:label].present?, "Category missing label"
      assert cat[:filters].is_a?(Hash), "Category filters should be a Hash"
    end
  end
end
