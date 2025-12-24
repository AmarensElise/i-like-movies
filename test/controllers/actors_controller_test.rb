require "test_helper"

class ActorsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    actor = actors(:one)
    get actor_url(actor)
    assert_response :success
  end
end
