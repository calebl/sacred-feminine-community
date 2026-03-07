const CACHE_VERSION = "v1"
const CACHE_NAME = `sacred-feminine-${CACHE_VERSION}`

// Cache app shell on install
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll([
        "/",
        "/icon-192.png",
        "/icon-512.png"
      ])
    })
  )
  self.skipWaiting()
})

// Clean up old caches on activate
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name.startsWith("sacred-feminine-") && name !== CACHE_NAME)
          .map((name) => caches.delete(name))
      )
    })
  )
  self.clients.claim()
})

// Network-first for navigations, cache-first for static assets
self.addEventListener("fetch", (event) => {
  const { request } = event
  const url = new URL(request.url)

  // Skip non-GET requests and cross-origin requests
  if (request.method !== "GET" || url.origin !== self.location.origin) return

  // Network-first for HTML navigations
  if (request.mode === "navigate") {
    event.respondWith(
      fetch(request)
        .then((response) => {
          const clone = response.clone()
          caches.open(CACHE_NAME).then((cache) => cache.put(request, clone))
          return response
        })
        .catch(() => caches.match(request).then((cached) => cached || caches.match("/")))
    )
    return
  }

  // Cache-first for static assets (images, CSS, JS, fonts)
  if (url.pathname.match(/\.(png|jpg|jpeg|svg|ico|css|js|woff2?)$/)) {
    event.respondWith(
      caches.match(request).then((cached) => {
        if (cached) return cached
        return fetch(request).then((response) => {
          const clone = response.clone()
          caches.open(CACHE_NAME).then((cache) => cache.put(request, clone))
          return response
        })
      })
    )
    return
  }
})

// Handle push notifications with app badge
self.addEventListener("push", (event) => {
  const { title, options } = event.data.json()
  const unreadCount = options.data?.unread_count

  event.waitUntil(
    Promise.all([
      self.registration.showNotification(title, options),
      updateBadge(unreadCount)
    ])
  )
})

self.addEventListener("notificationclick", (event) => {
  event.notification.close()
  event.waitUntil(
    Promise.all([
      clearBadge(),
      clients.matchAll({ type: "window" }).then((clientList) => {
        const targetPath = event.notification.data?.path || "/"
        for (const client of clientList) {
          const clientPath = new URL(client.url).pathname
          if (clientPath === targetPath && "focus" in client) {
            return client.focus()
          }
        }
        if (clients.openWindow) {
          return clients.openWindow(targetPath)
        }
      })
    ])
  )
})

// Badge API helpers — set/clear the PWA app icon badge
async function updateBadge(count) {
  if (!("setAppBadge" in navigator)) return
  try {
    if (typeof count === "number" && count > 0) {
      await navigator.setAppBadge(count)
    } else {
      const notifications = await self.registration.getNotifications()
      await navigator.setAppBadge(notifications.length + 1)
    }
  } catch (_) { /* Badge API not supported in this context */ }
}

async function clearBadge() {
  if (!("clearAppBadge" in navigator)) return
  try { await navigator.clearAppBadge() } catch (_) { /* noop */ }
}
