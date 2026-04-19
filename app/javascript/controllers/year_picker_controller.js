import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "centuryButtons",
    "centuryButton",
    "decadeGrid",
    "decadeButton",
    "yearGrid",
    "yearButton",
    "preview",
    "submit",
    "hiddenInput"
  ]

  static values = {
    currentYear: Number
  }

  connect() {
    this.century = null
    this.decadeDigit = null
    this.yearDigit = null
    this.render()
  }

  selectCentury(event) {
    this.century = event.currentTarget.dataset.century
    this.decadeDigit = null
    this.yearDigit = null
    this.render()
  }

  selectDecade(event) {
    this.decadeDigit = event.currentTarget.dataset.decade
    this.yearDigit = null
    this.render()
  }

  selectYear(event) {
    this.yearDigit = event.currentTarget.dataset.yearDigit
    this.render()
  }

  backToCentury() {
    this.century = null
    this.decadeDigit = null
    this.yearDigit = null
    this.render()
  }

  backToDecade() {
    this.decadeDigit = null
    this.yearDigit = null
    this.render()
  }

  render() {
    this.previewTarget.textContent = this.previewText()
    this.hiddenInputTarget.value = this.fullYear() || ""
    this.submitTarget.disabled = !this.fullYear()

    this.toggleDecadeGrid()
    this.toggleYearGrid()
    this.updateDecadeButtons()
    this.updateYearButtons()
    this.updateSelectionStyles()
  }

  previewText() {
    if (!this.century) return "_ _ _ _"
    if (!this.decadeDigit) return `${this.century} _ _`
    if (!this.yearDigit) return `${this.century}${this.decadeDigit} _`
    return this.fullYear()
  }

  fullYear() {
    if (!this.century || !this.decadeDigit || !this.yearDigit) return null
    return `${this.century}${this.decadeDigit}${this.yearDigit}`
  }

  toggleDecadeGrid() {
    this.decadeGridTarget.classList.toggle("hidden", !this.century || !!this.decadeDigit)
    this.centuryButtonsTarget.classList.toggle("hidden", !!this.century)
  }

  toggleYearGrid() {
    this.yearGridTarget.classList.toggle("hidden", !this.century || !this.decadeDigit)
  }

  updateDecadeButtons() {
    const allowed = this.allowedDecadeDigits()
    this.decadeButtonTargets.forEach((button) => {
      const enabled = allowed.includes(button.dataset.decade)
      button.classList.toggle("hidden", !enabled)
      button.disabled = !enabled
    })
  }

  updateYearButtons() {
    const maxDigit = this.maxYearDigit()
    this.yearButtonTargets.forEach((button) => {
      const digit = Number(button.dataset.yearDigit)
      const enabled = maxDigit === null || digit <= maxDigit
      button.classList.toggle("hidden", !enabled)
      button.disabled = !enabled
    })
  }

  allowedDecadeDigits() {
    if (this.century === "19") return ["2", "3", "4", "5", "6", "7", "8", "9"]
    if (this.century === "20") return ["0", "1", "2"]
    return []
  }

  maxYearDigit() {
    if (this.century === "20" && this.decadeDigit === "2") {
      return this.currentYearValue - 2020
    }
    return null
  }

  updateSelectionStyles() {
    this.centuryButtonTargets.forEach((button) => {
      this.toggleSelected(button, button.dataset.century === this.century)
    })

    this.decadeButtonTargets.forEach((button) => {
      this.toggleSelected(button, button.dataset.decade === this.decadeDigit)
    })

    this.yearButtonTargets.forEach((button) => {
      this.toggleSelected(button, button.dataset.yearDigit === this.yearDigit)
    })
  }

  toggleSelected(button, selected) {
    button.classList.toggle("border-indigo-600", selected)
    button.classList.toggle("text-indigo-600", selected)
    button.classList.toggle("bg-indigo-50", selected)
    button.setAttribute("aria-pressed", selected ? "true" : "false")
  }
}
