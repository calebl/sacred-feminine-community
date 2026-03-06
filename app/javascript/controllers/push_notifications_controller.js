import { Controller } from "@hotwired/stimulus"

// Manages Web Push notification subscription lifecycle.
// Connects to a button/banner that prompts users to enable notifications.
export default class extends Controller {
  static targets = ["banner"]

  connect() {
    if (!("serviceWorker" in navigator) || !("PushManager" in window) || !("Notification" in window)) {
      this.hideBanner()
      return
    }

    if (Notification.permission === "granted") {
      this.ensureSubscription()
      this.hideBanner()
    } else if (Notification.permission === "denied") {
      this.hideBanner()
    } else if (sessionStorage.getItem("pushNotificationsDismissed") === "true") {
      this.hideBanner()
    } else {
      this.showBanner()
    }
  }

  async enable() {
    const permission = await Notification.requestPermission()
    if (permission === "granted") {
      await this.ensureSubscription()
      this.hideBanner()
    } else {
      this.hideBanner()
    }
  }

  dismiss() {
    this.hideBanner()
    sessionStorage.setItem("pushNotificationsDismissed", "true")
  }

  async ensureSubscription() {
    try {
      const registration = await navigator.serviceWorker.ready
      let subscription = await registration.pushManager.getSubscription()

      if (!subscription) {
        const response = await fetch("/api/vapid_key", {
          headers: { "Accept": "application/json" }
        })
        if (!response.ok) return

        const { public_key } = await response.json()
        if (!public_key) return

        subscription = await registration.pushManager.subscribe({
          userVisibleOnly: true,
          applicationServerKey: this.urlBase64ToUint8Array(public_key)
        })
      }

      await this.syncSubscription(subscription)
    } catch (e) {
      console.error("Push subscription failed:", e)
    }
  }

  async syncSubscription(subscription) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    const json = subscription.toJSON()

    await fetch("/push_subscriptions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify({
        push_subscription: {
          endpoint: json.endpoint,
          p256dh_key: json.keys.p256dh,
          auth_key: json.keys.auth
        }
      })
    })
  }

  showBanner() {
    if (this.hasBannerTarget) {
      this.bannerTarget.hidden = false
    }
  }

  hideBanner() {
    if (this.hasBannerTarget) {
      this.bannerTarget.hidden = true
    }
  }

  // Decode a base64url-encoded string to a Uint8Array for applicationServerKey
  urlBase64ToUint8Array(base64String) {
    const padding = "=".repeat((4 - base64String.length % 4) % 4)
    const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/")
    const rawData = atob(base64)
    const outputArray = new Uint8Array(rawData.length)
    for (let i = 0; i < rawData.length; i++) {
      outputArray[i] = rawData.charCodeAt(i)
    }
    return outputArray
  }
}
