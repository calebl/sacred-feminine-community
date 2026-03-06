# Sacred Feminine Community Platform

A community platform built with Rails 8 for connecting members through cohort-based groups, encrypted direct messaging, interactive geographic mapping, and rich user profiles.

## Features

- **Cohort-based groups** — Organize members into cohorts with real-time group chat (ActionCable)
- **Encrypted direct messaging** — Private conversations with Rails native encryption
- **Interactive member map** — Geocoded member locations displayed on an interactive map
- **User profiles** — Profiles with avatars (Active Storage), city/country, and bios
- **Admin dashboard** — Invite-only registration, user management, and cohort administration
- **Audit trail** — Track changes to key records with the Audited gem
- **Soft-delete** — Safely discard records without permanent deletion

## Tech Stack

- **Ruby** 3.3.8 / **Rails** 8.1.2
- **Database:** SQLite3 (multi-database in production: primary, cache, queue, cable)
- **Frontend:** Hotwire (Turbo + Stimulus), TailwindCSS, Importmap, Propshaft
- **Auth:** Devise + devise_invitable, Pundit (policy-based authorization)
- **Real-time:** ActionCable via Solid Cable
- **Geocoding:** Geocoder gem, async via `GeocodeUserJob`
- **Deployment:** Kamal (Docker-based), Thruster for HTTP acceleration

## Getting Started

### Prerequisites

- **Ruby 3.3.8** — Install via [rbenv](https://github.com/rbenv/rbenv), [asdf](https://asdf-vm.com/), or [mise](https://mise.jdx.dev/)
- **Bundler** — `gem install bundler`
- **SQLite3** — Install via your system package manager (e.g. `apt install libsqlite3-dev` or `brew install sqlite3`)
- **Node.js** — Required for the TailwindCSS build watcher
- **libvips** — Required for Active Storage image processing (e.g. `apt install libvips` or `brew install vips`)

### Setup

Clone the repository and run the setup script:

```bash
git clone <repository-url>
cd sacred-feminine-community
bin/setup
```

This will install gem dependencies, prepare the database, and start the development server.

To set up without starting the server:

```bash
bin/setup --skip-server
```

To reset the database during setup:

```bash
bin/setup --reset
```

### Running the Dev Server

```bash
bin/dev
```

This starts both the Rails server and the TailwindCSS watcher.

### Creating Users

New users are added via admin invitation, but you can also create users from the command line:

```bash
# Interactive
rake users:create

# With flags
rake users:create -- --email=user@example.com --name="Jane Doe" --password=secret123 --role=admin --city=Surabaya --country=Indonesia

# List all users
rake users:list
```

### Credentials

This project uses Rails encrypted credentials (not `.env` files). To edit credentials:

```bash
bin/rails credentials:edit
```

## Testing

Tests use **Minitest** with parallel workers, fixtures for all models, and Capybara + Selenium for system tests.

```bash
bin/rails test         # Unit & integration tests
bin/rails test:system  # System tests (requires a browser driver)
```

### Full CI Pipeline

Run linting, security checks, and the full test suite:

```bash
bin/ci
```

Or run each check individually:

```bash
bin/rubocop            # Lint (rubocop-rails-omakase)
bin/brakeman           # Security static analysis
bin/bundler-audit      # Gem vulnerability audit
```

## Architecture Overview

### Key Directories

| Directory | Purpose |
|---|---|
| `app/controllers/admin/` | Admin dashboard, invitation management |
| `app/controllers/api/` | JSON API endpoints (map pins) |
| `app/models/` | Domain models |
| `app/policies/` | Pundit authorization policies |
| `app/jobs/` | Background jobs (geocoding) |

### Models

| Model | Description |
|---|---|
| `User` | Devise auth, roles (`attendee`/`admin`), geocoded by city/country, avatar |
| `Cohort` | Groups with memberships, created by admins |
| `ChatMessage` | Group chat within cohorts |
| `DirectMessage` | Encrypted DMs scoped to conversations |
| `Conversation` | DM threading between users |

### Routes

| Path | Description |
|---|---|
| `/` | Dashboard (authenticated) or sign-in |
| `/cohorts` | Cohort listing, chat, memberships |
| `/conversations` | Direct message conversations |
| `/profiles/:id` | User profiles |
| `/map` | Interactive member map |
| `/admin/dashboard` | Admin panel (admin role required) |
| `/api/map_pins` | JSON endpoint for map pin data |

### Authorization

All controllers enforce authorization via Pundit. There are two roles:

- **attendee** (default) — Standard member access
- **admin** — Full access including the admin dashboard, user invitations, and cohort management
