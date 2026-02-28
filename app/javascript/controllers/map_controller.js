import { Controller } from "@hotwired/stimulus"
import L from "leaflet"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.map = L.map(this.element).setView([30, 10], 2)

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 18,
    }).addTo(this.map)

    this.loadPins()
  }

  async loadPins() {
    const response = await fetch(this.urlValue, {
      headers: {
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      }
    })
    const pins = await response.json()

    pins.forEach(pin => {
      const marker = L.marker([pin.lat, pin.lng]).addTo(this.map)

      const container = document.createElement("div")
      container.className = "text-center"

      const name = document.createElement("strong")
      name.textContent = pin.name
      container.appendChild(name)

      container.appendChild(document.createElement("br"))

      const location = document.createElement("span")
      location.className = "text-gray-500"
      location.textContent = `${pin.city}, ${pin.country}`
      container.appendChild(location)

      container.appendChild(document.createElement("br"))

      const link = document.createElement("a")
      link.href = `/profiles/${encodeURIComponent(pin.id)}`
      link.className = "text-blue-600 text-sm"
      link.textContent = "View Profile"
      container.appendChild(link)

      marker.bindPopup(container)
    })

    if (pins.length > 0) {
      const bounds = L.latLngBounds(pins.map(p => [p.lat, p.lng]))
      this.map.fitBounds(bounds, { padding: [50, 50] })
    }
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }
}
