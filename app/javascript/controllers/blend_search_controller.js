// app/javascript/controllers/blend_search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "hidden"]
  static values = { url: String }

  connect() {
    this.resultsTarget.innerHTML = ''
  }

  search() {
    const query = this.inputTarget.value.trim()
    if (query.length < 2) {
      this.resultsTarget.innerHTML = ''
      return
    }
    fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`)
      .then(r => r.json())
      .then(movies => {
        this.resultsTarget.innerHTML = ''
        movies.forEach(movie => {
          const option = document.createElement('div')
          option.textContent = movie.title
          option.className = 'cursor-pointer px-2 py-1 hover:bg-indigo-100'
          option.addEventListener('click', () => {
            this.inputTarget.value = movie.title
            this.hiddenTarget.value = movie.id
            this.resultsTarget.innerHTML = ''
          })
          this.resultsTarget.appendChild(option)
        })
      })
  }
}
