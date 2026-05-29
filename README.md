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

### Deploying with Once

This app is compatible with [Once](https://github.com/basecamp/once), Basecamp's platform for self-hosted web applications.

#### Prerequisites

- A server running Once (see [Once installation docs](https://github.com/basecamp/once))
- A Docker image of this app pushed to a registry accessible by your Once server

#### Building and pushing the image

```bash
docker build -t your-registry.com/sacred-feminine:latest .
docker push your-registry.com/sacred-feminine:latest
```

#### Installing on Once

From the Once dashboard, add a new application with the Docker image path (`your-registry.com/sacred-feminine:latest`) and assign a hostname.

Once automatically provides the following environment variables — no manual configuration needed:

| Variable | Purpose |
|---|---|
| `SECRET_KEY_BASE` | Rails secret key for signing/encryption |
| `DISABLE_SSL` | Set when not behind an SSL-terminating proxy |
| `VAPID_PUBLIC_KEY` | Web Push public key |
| `VAPID_PRIVATE_KEY` | Web Push private key |
| `SMTP_SERVER` | Mail server address |
| `SMTP_PORT` | Mail server port |
| `SMTP_LOGIN` | Mail server username |
| `SMTP_PASSWORD` | Mail server password |
| `NUM_CPUS` | Available CPUs (used to auto-scale Puma workers) |

#### Migrating an existing deployment to Once

If you've already deployed this app with a different `SECRET_KEY_BASE`, switching to Once's auto-generated key will break encrypted data (direct messages use Rails encryption) and invalidate all user sessions. To avoid this, set Once's `SECRET_KEY_BASE` to match your existing value. Consult the Once documentation for how to override injected environment variables.

#### How it works

- **Port 80**: The app serves HTTP on port 80 via Thruster, as Once expects.
- **Health check**: Once monitors `/up` to verify the app is running.
- **Storage**: Once mounts `/rails/storage` for persistent SQLite databases and Active Storage files.
- **SSL**: When `DISABLE_SSL` is set, the app disables `force_ssl` and switches mailer/ActionCable URLs to HTTP.
- **Email**: If `SMTP_SERVER` is provided by Once, the app uses SMTP delivery. Otherwise it falls back to the Resend HTTP API.
- **VAPID keys**: Once-provided env vars take priority over Rails credentials.
- **Backups**: The `hooks/pre-backup` script checkpoints all SQLite WAL files for consistent snapshots. After a restore, `hooks/post-restore` runs pending database migrations.
