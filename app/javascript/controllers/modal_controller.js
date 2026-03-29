import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
// Opens/closes a turbo-frame modal overlay
export default class extends Controller {
  static targets = ["overlay"]

  open() {
    this.overlayTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  close() {
    this.overlayTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  // Close on Escape key
  closeWithKeyboard(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  // Close when clicking overlay background
  closeBackground(event) {
    if (event.target === this.overlayTarget) {
      this.close()
    }
  }
}
