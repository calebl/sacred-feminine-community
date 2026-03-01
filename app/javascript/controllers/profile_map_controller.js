import { Controller } from "@hotwired/stimulus"
import L from "leaflet"

export default class extends Controller {
  static values = {
    latitude: Number,
    longitude: Number
  }

  connect() {
    this.map = L.map(this.element, {
      zoomControl: false,
      scrollWheelZoom: false,
      dragging: false,
      doubleClickZoom: false,
      boxZoom: false,
      keyboard: false,
      touchZoom: false
    }).setView([this.latitudeValue, this.longitudeValue], 10)

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      maxZoom: 18,
    }).addTo(this.map)

    L.marker([this.latitudeValue, this.longitudeValue]).addTo(this.map)
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }
}
