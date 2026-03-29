import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autosave"
// Auto-saves a form field on blur by submitting via fetch
export default class extends Controller {
  static targets = ["form"]

  save() {
    const form = this.formTarget
    const formData = new FormData(form)

    fetch(form.action, {
      method: form.method || "PATCH",
      body: formData,
      headers: {
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      }
    })
  }
}
