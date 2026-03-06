# Sacred Feminine Community Platform

A Rails 8 community platform with encrypted messaging, cohort-based groups, geographic mapping, user profiles, and PWA push notifications.

## Tech Stack

- Ruby 3.3.8 / Rails 8.1.2
- SQLite3 (multi-database in production)
- Hotwire (Turbo + Stimulus), TailwindCSS, Importmap, Propshaft
- Devise + devise_invitable, Pundit
- ActionCable (Solid Cable) for real-time chat and DM notifications
- Web Push notifications via the `web-push` gem

## Local Setup

```bash
bin/setup       # Install deps, prepare DB
bin/dev         # Start dev server (Rails + TailwindCSS watcher)
```

### Push Notifications (Local)

Push notifications require VAPID keys. Generate a keypair:

```bash
bin/rails runner "keys = WebPush.generate_key; puts 'public:  ' + keys.public_key; puts 'private: ' + keys.private_key"
```

Add the keys to your development credentials:

```bash
bin/rails credentials:edit --environment development
```

```yaml
vapid:
  public_key: <public_key>
  private_key: <private_key>
```

Push notifications work on `localhost` without HTTPS. Open the app in Chrome, Edge, or Safari. A banner will prompt users to enable notifications. When a DM is sent, recipients with notifications enabled will receive a browser push notification.

If VAPID keys are not configured, the app runs normally — push notifications are silently skipped.

## Running Tests

```bash
bin/rails test         # Unit & integration tests
bin/rails test:system  # System tests (Capybara + Selenium)
bin/ci                 # Full CI pipeline (lint, security, tests)
```

## Production Setup

### VAPID Keys

Generate a **separate** keypair for production (do not reuse development keys):

```bash
bin/rails runner "keys = WebPush.generate_key; puts 'public:  ' + keys.public_key; puts 'private: ' + keys.private_key"
```

Add them to production credentials:

```bash
EDITOR=vim bin/rails credentials:edit --environment production
```

```yaml
vapid:
  public_key: <production_public_key>
  private_key: <production_private_key>
```

Alternatively, set the `VAPID_PUBLIC_KEY` and `VAPID_PRIVATE_KEY` environment variables.

### Deployment

The app deploys with Kamal (Docker-based) using Thruster for HTTP acceleration. See `config/deploy.yml` for configuration.
