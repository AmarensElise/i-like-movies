require "application_system_test_case"

class QuizFlowTest < ApplicationSystemTestCase
  test "user completes the quiz flow" do
    visit new_user_session_path
    fill_in "Email", with: users(:three).email
    fill_in "Password", with: "password123"
    click_button "Log in"

    visit new_quiz_path
    click_button "Start Quiz ->"

    assert_text "Question 1 of 10"

    9.times do
      submit_guess_2000
      assert_text "Actual year"
      click_link "Next ->"
    end

    submit_guess_2000
    assert_text "Actual year"
    click_link "See Results ->"

    assert_text "Quiz Complete"
    assert_text "View leaderboard"
  end

  private

  def submit_guess_2000
    find("button[data-century='20']").click
    find("button[data-decade='0']", visible: true).click
    find("button[data-year-digit='0']", visible: true).click
    click_button "Submit Guess"
  end
end
