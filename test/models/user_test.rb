require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "username is normalized before validation" do
    user = User.new(
      email: "normalized@example.com",
      username: "  Mixed_Name  ",
      password: "password123",
      password_confirmation: "password123"
    )

    assert user.valid?
    assert_equal "mixed_name", user.username
  end

  test "username must match allowed format" do
    user = User.new(
      email: "invalid@example.com",
      username: "bad name!",
      password: "password123",
      password_confirmation: "password123"
    )

    assert_not user.valid?
    assert_includes user.errors[:username], "is invalid"
  end

  test "username is unique case insensitively" do
    user = User.new(
      email: "duplicate@example.com",
      username: users(:one).username.upcase,
      password: "password123",
      password_confirmation: "password123"
    )

    assert_not user.valid?
    assert_includes user.errors[:username], "has already been taken"
  end
end
