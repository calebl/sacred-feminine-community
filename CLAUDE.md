# Sacred Feminine Community Platform

A Rails 8 community platform with encrypted messaging, cohort-based groups, geographic mapping, and user profiles.

## Tech Stack

- **Ruby** 3.3.8 / **Rails** 8.1.2
- **Database:** SQLite3 (multi-database in production: primary, cache, queue, cable)
- **Frontend:** Hotwire (Turbo + Stimulus), TailwindCSS, Importmap, Propshaft
- **Auth:** Devise + devise_invitable, Pundit (policy-based authorization)
- **Real-time:** ActionCable (Solid Cable) for direct messaging
- **Encryption:** Rails native encryption on `DirectMessage.body`
- **Geocoding:** Geocoder gem, async via `GeocodeUserJob`
- **Deployment:** Kamal (Docker-based), Thruster for HTTP acceleration

## Common Commands

```bash
bin/setup              # Install deps, prepare DB, start dev server
bin/dev                # Start dev server (Rails + TailwindCSS watcher)
bin/rails test         # Run unit & integration tests
bin/rails test:system  # Run system tests (Capybara + Selenium)
bin/ci                 # Full CI pipeline (lint, security, tests)
bin/rubocop            # Lint (rubocop-rails-omakase style)
bin/brakeman           # Security static analysis
bin/bundler-audit      # Gem vulnerability audit
```

### User Management CLI

```bash
# Create user interactively
rake users:create

# Create user with flags
rake users:create -- --email=user@example.com --name="Jane Doe" --password=secret123 --role=admin --city=Surabaya --country=Indonesia

# List all users
rake users:list
```

## Architecture

### Key Directories

- `app/controllers/admin/` - Admin dashboard, invitation management
- `app/controllers/api/` - JSON endpoints for map pins and the versioned native app API
- `app/models/` - User, Cohort, CohortMembership, Conversation, ConversationParticipant, DirectMessage, ApiToken
- `app/policies/` - Pundit policies for all models
- `app/jobs/` - GeocodeUserJob (async geocoding)

### Models

- **User** - Devise auth, roles (`attendee`/`admin`), privacy enums (`dm_privacy`, `mention_privacy`, `cohort_gender_privacy`), geocoded by city/country, avatar (Active Storage). `hidden_content_user_ids` is the single choke point for hiding another user's content (blocks + cohort gender filtering)
- **Cohort** - Groups with memberships, created by an admin user
- **DirectMessage** - Encrypted body, scoped to conversations
- **Conversation** / **ConversationParticipant** - DM threading between users
- **ApiToken** - Digested bearer tokens for native app device sessions

### Routes

- `/` - Redirects to sign-in (unauthenticated) or dashboard (authenticated)
- `/cohorts` - Cohort CRUD with nested posts and memberships
- `/conversations` - Direct message conversations with nested messages
- `/profiles/:id` - User profiles (view/edit own)
- `/map` - Interactive member map; `/api/map_pins` for pin data
- `/api/v1` - Bearer-token native app API; endpoint details and contracts are documented in [FEATURES.md](FEATURES.md) and `test/api_examples/`
- `/admin/dashboard` - Admin panel (admin role required)

### Auth & Authorization

- All controllers use Pundit. Call `authorize` for individual records, `policy_scope` for collections.
- Roles: `attendee` (default, 0) and `admin` (1) via integer enum on User.
- Invitations flow through `Admin::InvitationsController` (admin-only).

## Features

See [FEATURES.md](FEATURES.md) for a comprehensive list of all platform features. **When adding, modifying, or removing features, update FEATURES.md to reflect the change.**

## Testing

- Framework: Minitest with parallel workers
- Test data comes from Oaken seeds, not Rails fixtures. Shared/test-only seeds live in
  `db/seeds/` and `db/seeds/test/`; reach records with dot notation (`users.admin`,
  `cohorts.kabul_retreat`), not the old `users(:admin)` fixture accessors. Add new test
  records by editing the matching `db/seeds/test/*.rb` file. `test/fixtures/files/` is
  still used for `file_fixture` uploads.
- Geocoder is stubbed in test_helper.rb (returns NYC coordinates)
- Devise test helpers included for integration tests
- All new changes in PRs must include test coverage for the introduced behavior

## Code Style

- Follow rubocop-rails-omakase conventions
- ERB templates (not Haml/Slim)
- Pundit `authorize`/`policy_scope` in every controller action
- Rails encrypted credentials (`bin/rails credentials:edit`), not .env files
- Keep controllers slim with only standard CRUD actions (`index`, `show`, `new`, `create`, `edit`, `update`, `destroy`). For non-CRUD operations, extract a new controller with its own CRUD action (e.g., `Admin::Users::RolesController#update` instead of `Admin::UsersController#change_role`).
