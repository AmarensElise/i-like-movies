import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sticker-picker"
// Toggles visibility of the sticker picker panel
export default class extends Controller {
  static targets = ["panel"]

  toggle() {
    this.panelTarget.classList.toggle("hidden")
  }

  close() {
    this.panelTarget.classList.add("hidden")
  }
}
