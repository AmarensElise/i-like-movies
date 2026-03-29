import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="rating"
// Handles star-based rating selection
export default class extends Controller {
  static targets = ["star", "input"]
  static values = { current: Number }

  select(event) {
    const rating = parseInt(event.currentTarget.dataset.ratingValue)
    this.currentValue = rating
    this.inputTarget.value = rating
    this.updateStars()

    // Submit the form
    this.inputTarget.closest("form").requestSubmit()
  }

  updateStars() {
    this.starTargets.forEach((star, index) => {
      if (index < this.currentValue) {
        star.classList.add("text-yellow-400")
        star.classList.remove("text-gray-300")
      } else {
        star.classList.remove("text-yellow-400")
        star.classList.add("text-gray-300")
      }
    })
  }

  currentValueChanged() {
    this.updateStars()
  }
}
