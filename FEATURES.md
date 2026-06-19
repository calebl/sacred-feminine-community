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
- **Author links to profiles** - Names and avatars link to the author's profile wherever they appear (feed/cohort/group posts and comments, direct messages, conversation header, help desk, blocked-users list), via the shared `shared/_avatar` partial. Links are omitted where a profile link would be invalid or misleading (notification rows, conversation list rows, DM toasts, autocomplete dropdowns, and one's own profile/self contexts).
- **Avatar upload** - Profile photos stored via Active Storage with cropping support (image_cropper Stimulus controller)
- **Bio and location fields** - Name, bio, city, state, country
- **Map visibility toggle** - Users opt in/out of appearing on the member map (`show_on_map`)
- **DM privacy settings** - All users (including admins) control who can message them: nobody, cohort members only, or everyone

## Cohorts
- **CRUD management** - Admins create cohorts with name, description, header image, and retreat date range
- **Men's cohort designation** - Cohorts can be flagged as a Men's Cohort via a checkbox in the admin form; flagged cohorts display a "Men's" badge on the cohort card
- **Membership** - Users are added to cohorts; membership tracks read state for posts
- **Discussion posts** - Members create posts within a cohort with comments, pinning, and unread tracking
- **Photo attachments** - Attach up to 10 photos (JPEG, PNG, GIF, WebP) per post with inline preview and gallery display
- **Post pinning** - Admins can pin important posts to the top of the feed
- **Unread tracking** - Tracks unread posts per member via `last_read_at` timestamps
- **Auto-join on invitation** - Users invited to specific cohorts are automatically added on acceptance

## Groups
- **User-created groups** - Any member can create groups with name and description
- **Membership** - Members join/leave groups; creator is auto-added
- **Discussion posts** - Members create posts within a group with comments, pinning, and unread tracking
- **Photo attachments** - Attach up to 10 photos per post with inline preview and gallery display
- **Post pinning** - Group creators/admins can pin posts
- **Unread tracking** - Tracks unread posts per member
- **Admin access** - Admins can view, post, and reply in any group without joining
- **Soft-delete (archive)** - Groups are archived rather than permanently deleted

## Community Feed
- **Public feed** - All authenticated members can post to and view a shared community feed
- **Feed posts** - Create, edit, delete posts with inline reply forms
- **Photo attachments** - Attach up to 10 photos per post with inline preview and gallery display
- **Comments** - Threaded comments on feed posts with expandable reply sections
- **Post pinning** - Admins can pin feed posts
- **Unread tracking** - Tracks unread comments per user

## Direct Messaging
- **Encrypted messages** - Message bodies encrypted at rest using Rails native encryption
- **Conversations** - One-to-one threaded conversations between users
- **Member search** - Search for members when starting a new conversation
- **Real-time delivery** - Messages broadcast via Turbo Streams to conversation participants
- **DM notifications** - Real-time notification popover for incoming DMs (configurable per user)
- **DM privacy controls** - All users (including admins) can restrict who can initiate DMs (nobody, cohort members, everyone); admins can always send DMs regardless of recipient settings, except to users who have blocked them
- **Unread counts** - Per-conversation unread message tracking

## @Mentions
- **Inline mentions** - @mention users in posts, comments, and DMs using `@[Name](id)` syntax
- **Autocomplete popup** - Mention search with popup positioned above the cursor in contenteditable fields
- **Notification tracking** - Mentions generate notifications; read/unread state is tracked via the unified Notification model
- **Cross-context support** - Works in posts, comments, and direct messages
- **Mention privacy settings** - Users control where they can be @mentioned: everywhere, groups and cohorts only, or nowhere. Privacy is enforced in the autocomplete dropdown (excluding users from contexts that violate their setting) as well as at notification time. Conversation/DM dropdowns are exempt — participants always appear there.

## Emoji Reactions
- **Polymorphic reactions** - React to posts and comments with emojis
- **Allowed set** - Six emoji options: thumbs up, heart, laughing, surprised, prayer, fire
- **One reaction per user** - Users can place one reaction per item, changeable via update
- **Grouped display** - Reactions shown as aggregated counts by emoji
- **Hover to see who reacted** - Hovering a reaction pill reveals a tooltip listing the names of everyone who reacted with that emoji

## Notifications
- **Unified notification model** - Single `Notification` model is the source of truth for all alerts (mentions, DMs, comments on your posts, admin events)
- **Notification center** - Dedicated page showing the 30 most recent notifications with read/unread styling and event-type-based icons
- **Mark all as read** - One-click button to mark all unread notifications as read
- **Mention notifications** - Users receive a notification when @mentioned in posts, comments, or DMs
- **DM notifications** - Users receive a notification for new direct messages, batched per conversation while unread
- **Comment notifications** - Post authors and prior commenters receive a notification when new comments are added
- **Admin invitation alerts** - Admins receive an in-app notification when a user accepts an invitation
- **Background job processing** - Notifications created via `CreateNotificationJob` with group_key dedup for batching
- **Block-aware suppression** - `CreateNotificationJob` skips any notification (and its push/email/badge side effects) when the recipient and actor are in a block relationship, in either direction. Centralized so it applies to every event type (mentions, comments, posts, DMs, group joins, etc.). Operational support-thread alerts (`help_request`, `help_request_reply`) are exempt so they always reach their recipients regardless of blocks.
- **Web Push notifications** - Opt-in browser push notifications via VAPID/Web Push, triggered by the notification job
- **Email notifications** - Master on/off toggle plus per-event-type toggles (mentions, DMs, new posts in your groups/cohorts, comments on your posts). Help request replies always send an email (subject to the master toggle). New members joining and new help requests never send email. Emails include only the generic notification title/body and links to the app and settings — no site content (message bodies, comment text, etc.). Delivered via `SendEmailNotificationJob` using Resend.com.
- **Email rate-limit retries** - When Resend rate-limits us (HTTP 429), email jobs automatically retry (up to 5 attempts), waiting the duration Resend reports in its `retry-after` header before trying again. Covers both the asynchronous Devise/`deliver_later` path (via `ResendMailDeliveryJob`) and notification emails (via `ResendRateLimitRetryable` on `ApplicationJob`).
- **New post notifications** - Members receive in-app, push, and email notifications when a new post is created in one of their groups or cohorts (author excluded; mentioned users receive only the mention notification to avoid duplicates).
- **Admin community-feed announcements** - When an admin posts on the main community feed, every other user receives an in-app, push, and email `new_post` notification linking to the post. Feed posts by non-admin members do not broadcast (only their @mentions notify). Author and mentioned users are excluded to avoid duplicates; block-aware suppression and per-user email preferences (`email_on_new_post?`) apply as usual.
- **New group member notifications** - Existing members of a group receive an in-app and push notification (no email) when a new person joins, linking to the group (the joining member is excluded; block-aware suppression is applied centrally in `CreateNotificationJob`).
- **Real-time unread badges** - Navbar badge counts update in real-time via Turbo Streams, powered by `notifications.unread.count`
- **Per-context unread indicators** - Gold dots show *where* unread activity is: next to "Messages" in the top bar (unread DM notifications) and to the left of each cohort/group in the sidebar (unread posts, comments, or mentions). New members joining a group do not light the dot. Driven by the `Notification` model and broadcast in real time over the same `[user, :unread_badge]` Turbo stream as the count badges.
- **Scroll-into-view read marking** - A cohort/group dot clears as the specific post or comment actually scrolls into view (`read-on-view` Stimulus controller → `Notifications::SeenController`). Comments are collapsed by default, so they only count as seen once expanded and on screen. Note: `new_comment` notifications are grouped per post, so seeing one new comment clears the post's whole group.
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

## Help Desk
- **Ask for help** - Attendees submit help requests with a subject and detailed description
- **Shared admin inbox** - All admins see every help request; attendees see only their own
- **Threaded replies** - Admins and the request author can reply back and forth on each request
- **Status management** - Admins can close and reopen help requests
- **Notifications** - Admins are notified of new requests; participants are notified of new replies

## Admin Panel
- **Admin dashboard** - Overview panel for admin users
- **User management** - View all users, remove (soft-delete), restore removed users
- **Role management** - Promote/demote users between attendee and admin roles
- **Invitation management** - Send invitations with optional cohort pre-assignment
- **Bulk invitations** - Invite multiple users by email to a specific cohort at once, with an optional custom message included in the invitation email
- **Invite links** - Generate shareable invitation links for specific users
- **Impersonation** - Admins can impersonate users in development environment for debugging
- **Job dashboard** - Solid Queue job monitoring via Mission Control (admin only)
- **Changelog** - Automatic release changelog recorded on each Kamal deploy; viewable from admin dashboard
- **Features overview** - FEATURES.md rendered as a styled page accessible from admin dashboard, showing the current platform feature set

## Privacy & Blocking
- **Block users** - Users can block other members from their profile page. Blocking is mutual for visibility: once a block exists, neither party sees the other's posts and comments across cohort, group, and community feeds or on individual post pages (a blocked user can no longer see the blocker's content either).
- **Admins cannot be blocked** - Admins are exempt from being blocked: the Block button is hidden on an admin's profile and the block is rejected at the model level if attempted directly.
- **Mention rendering** - @mentions are rendered as plain text (no profile link) for both parties whenever a block exists between them
- **Mention autocomplete** - Users on either side of a block are excluded from each other's @mention autocomplete dropdown
- **Direct messages** - Blocking prevents direct messages in both directions: neither party can start or send a DM to the other, and the "Send Message" button is hidden on the profile. This overrides DM privacy settings and applies even to admins.
- **Map visibility** - Blocking is mutual on the member map: neither party sees the other's pin once a block exists, regardless of their `show_on_map` setting.
- **Blocked users list** - Users can view all blocked users from their profile page and unblock anyone from that list

## Account Settings
- **Email change** - Users can update their email address
- **Password change** - Users can update their password (requires current password)

## Real-time Features
- **Turbo Streams** - DMs broadcast in real-time without page reload
- **ActionCable** - WebSocket-backed real-time updates via Solid Cable

## UI/UX
- **Theme preference** - Users choose light, dark, or system (match device) appearance from their profile edit page. Saved per-user (defaults to light) and applied server-side on page load to avoid flicker.
- **Responsive layout** - TailwindCSS-based responsive design
- **Clipboard copying** - Copy-to-clipboard functionality for invite links
- **Confirmation dialogs** - Custom confirmation dialog for destructive actions
- **Tab navigation** - Tabbed interfaces for cohort/group views
- **Local time display** - Timestamps converted to user's local timezone
- **Inline post forms** - Create posts directly from the feed without navigating away
- **Expandable replies** - Reply sections expand/collapse inline on feed posts
