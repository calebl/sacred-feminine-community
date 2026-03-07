# Features

## Authentication & User Management
- **Invitation-only registration** - Admins invite users via email; new users accept invitations to join
- **Devise authentication** - Email/password sign-in with password recovery
- **Role-based access** - Two roles: `attendee` (default) and `admin`
- **Soft-delete users** - Admins can remove users (soft-delete via Discard); removed users can be restored
- **Audit logging** - User changes tracked via the Audited gem

## Dashboard
- **Tabbed dashboard layout** - Authenticated users land on a dashboard with feed, map, and members panels
- **Sidebar navigation** - Shows the user's cohorts and groups with links

## User Profiles
- **View/edit profiles** - Users can view any member's profile and edit their own
- **Avatar upload** - Profile photos stored via Active Storage with cropping support (image_cropper Stimulus controller)
- **Bio and location fields** - Name, bio, city, state, country
- **Map visibility toggle** - Users opt in/out of appearing on the member map (`show_on_map`)
- **DM privacy settings** - All users (including admins) control who can message them: nobody, cohort members only, or everyone

## Cohorts
- **CRUD management** - Admins create cohorts with name, description, header image, and retreat date range
- **Membership** - Users are added to cohorts; membership tracks read state for posts
- **Discussion posts** - Members create posts within a cohort with comments, pinning, and unread tracking
- **Post pinning** - Admins can pin important posts to the top of the feed
- **Unread tracking** - Tracks unread posts per member via `last_read_at` timestamps
- **Auto-join on invitation** - Users invited to specific cohorts are automatically added on acceptance

## Groups
- **User-created groups** - Any member can create groups with name, description, and header image
- **Membership** - Members join/leave groups; creator is auto-added
- **Discussion posts** - Members create posts within a group with comments, pinning, and unread tracking
- **Post pinning** - Group creators/admins can pin posts
- **Unread tracking** - Tracks unread posts per member
- **Soft-delete (archive)** - Groups are archived rather than permanently deleted

## Community Feed
- **Public feed** - All authenticated members can post to and view a shared community feed
- **Feed posts** - Create, edit, delete posts with inline reply forms
- **Comments** - Threaded comments on feed posts with expandable reply sections
- **Post pinning** - Admins can pin feed posts
- **Unread tracking** - Tracks unread comments per user

## Direct Messaging
- **Encrypted messages** - Message bodies encrypted at rest using Rails native encryption
- **Conversations** - One-to-one threaded conversations between users
- **Member search** - Search for members when starting a new conversation
- **Real-time delivery** - Messages broadcast via Turbo Streams to conversation participants
- **DM notifications** - Real-time notification popover for incoming DMs (configurable per user)
- **DM privacy controls** - All users (including admins) can restrict who can initiate DMs (nobody, cohort members, everyone); admins can always send DMs regardless of recipient settings
- **Unread counts** - Per-conversation unread message tracking

## @Mentions
- **Inline mentions** - @mention users in posts, comments, and DMs using `@[Name](id)` syntax
- **Autocomplete popup** - Mention search with popup positioned above the cursor in contenteditable fields
- **Notification tracking** - Mentions generate notifications; read/unread state is tracked via the unified Notification model
- **Cross-context support** - Works in posts, comments, and direct messages
- **Mention privacy settings** - Users control where they can be @mentioned: everywhere, groups and cohorts only, or nowhere

## Emoji Reactions
- **Polymorphic reactions** - React to posts and comments with emojis
- **Allowed set** - Six emoji options: thumbs up, heart, laughing, surprised, prayer, fire
- **One reaction per user** - Users can place one reaction per item, changeable via update
- **Grouped display** - Reactions shown as aggregated counts by emoji

## Notifications
- **Unified notification model** - Single `Notification` model is the source of truth for all alerts (mentions, DMs, comments on your posts, admin events)
- **Notification center** - Dedicated page showing the 30 most recent notifications with read/unread styling and event-type-based icons
- **Mark all as read** - One-click button to mark all unread notifications as read
- **Mention notifications** - Users receive a notification when @mentioned in posts, comments, or DMs
- **DM notifications** - Users receive a notification for new direct messages, batched per conversation while unread
- **Comment notifications** - Post authors and prior commenters receive a notification when new comments are added
- **Admin invitation alerts** - Admins receive an in-app notification when a user accepts an invitation
- **Background job processing** - Notifications created via `CreateNotificationJob` with group_key dedup for batching
- **Web Push notifications** - Opt-in browser push notifications via VAPID/Web Push, triggered by the notification job
- **Real-time unread badges** - Navbar badge counts update in real-time via Turbo Streams, powered by `notifications.unread.count`
- **PWA app icon badge** - Accurate server-side unread count displayed on the PWA app icon via the Badge API

## Interactive Map
- **Member map** - Leaflet-based interactive map showing opted-in members' locations
- **Geocoding** - Async geocoding of user locations via `GeocodeUserJob` (city/state/country to lat/lng)
- **Profile map** - Individual profile pages show a mini-map of the user's location
- **API endpoint** - `/api/map_pins` serves pin data as JSON

## FAQs
- **Admin-managed** - Admins create and manage FAQ entries (question/answer pairs)
- **Ordering** - FAQs are ordered by position and creation date
- **Active/inactive toggle** - FAQs can be toggled on/off

## Admin Panel
- **Admin dashboard** - Overview panel for admin users
- **User management** - View all users, remove (soft-delete), restore removed users
- **Role management** - Promote/demote users between attendee and admin roles
- **Invitation management** - Send invitations with optional cohort pre-assignment
- **Invite links** - Generate shareable invitation links for specific users
- **Impersonation** - Admins can impersonate users in development environment for debugging
- **Job dashboard** - Solid Queue job monitoring via Mission Control (admin only)
- **Changelog** - Automatic release changelog recorded on each Kamal deploy; viewable from admin dashboard
- **Features overview** - FEATURES.md rendered as a styled page accessible from admin dashboard, showing the current platform feature set

## Account Settings
- **Email change** - Users can update their email address
- **Password change** - Users can update their password (requires current password)

## Real-time Features
- **Turbo Streams** - DMs broadcast in real-time without page reload
- **ActionCable** - WebSocket-backed real-time updates via Solid Cable

## UI/UX
- **Dark mode** - Toggle between light and dark themes (Stimulus controller)
- **Responsive layout** - TailwindCSS-based responsive design
- **Clipboard copying** - Copy-to-clipboard functionality for invite links
- **Confirmation dialogs** - Custom confirmation dialog for destructive actions
- **Tab navigation** - Tabbed interfaces for cohort/group views
- **Local time display** - Timestamps converted to user's local timezone
- **Inline post forms** - Create posts directly from the feed without navigating away
- **Expandable replies** - Reply sections expand/collapse inline on feed posts
