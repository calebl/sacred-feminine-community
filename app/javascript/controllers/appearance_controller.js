import { Controller } from "@hotwired/stimulus"

// Applies the user's saved theme on every page load and Turbo navigation.
// Turbo preserves the <html> element across visits, so the dark class set by
// the inline <head> script on first load would otherwise go stale after the
// user changes their theme and saves. This re-applies it from the server-
// rendered value carried on <body>, which Turbo does re-render.
export default class extends Controller {
  static values = { theme: String }

  connect() {
    this.apply()
  }

  themeValueChanged() {
    this.apply()
  }

  apply() {
    const theme = this.themeValue
    const dark = theme === "dark" ||
      (theme === "system" && window.matchMedia("(prefers-color-scheme: dark)").matches)
    document.documentElement.classList.toggle("dark", dark)
    document.documentElement.dataset.theme = theme
  }
}
