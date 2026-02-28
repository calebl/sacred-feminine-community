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
      marker.bindPopup(`
        <div class="text-center">
          <strong>${pin.name}</strong><br>
          <span class="text-gray-500">${pin.city}, ${pin.country}</span><br>
          <a href="/profiles/${pin.id}" class="text-blue-600 text-sm">View Profile</a>
        </div>
      `)
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
