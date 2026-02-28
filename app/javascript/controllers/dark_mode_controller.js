import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (localStorage.getItem("darkMode") === "true" ||
        (!localStorage.getItem("darkMode") && window.matchMedia("(prefers-color-scheme: dark)").matches)) {
      document.documentElement.classList.add("dark")
    }
  }

  toggle() {
    document.documentElement.classList.toggle("dark")
    localStorage.setItem("darkMode", document.documentElement.classList.contains("dark"))
  }
}
