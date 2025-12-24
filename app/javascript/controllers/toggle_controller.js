import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "label"]

  connect() {
    // no-op
  }

  toggle(event) {
    event && event.preventDefault()
    if (this.hasPanelTarget) {
      this.panelTarget.classList.toggle('hidden')
    }
  }
}
