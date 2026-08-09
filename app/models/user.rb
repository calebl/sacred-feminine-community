class User < ApplicationRecord
  include Discard::Model
  include UnreadIndicators

  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :validatable

  attr_accessor :current_password

  serialize :invited_cohort_ids, coder: JSON, type: Array

  audited except: [ :encrypted_password, :reset_password_token, :reset_password_sent_at,
                    :remember_created_at, :invitation_token, :invitation_sent_at,
                    :invitation_accepted_at, :invitation_created_at, :current_password,
                    :invited_cohort_ids, :bulk_invitation_id ]

  enum :role, { attendee: 0, admin: 1 }
  enum :dm_privacy, { nobody: 0, cohort_members: 1, everyone: 2 }, prefix: true
  enum :mention_privacy, { nobody: 0, groups_and_cohorts: 1, everywhere: 2 }, prefix: :mention_privacy
  enum :theme, { light: 0, dark: 1, system: 2 }, prefix: true
  enum :cohort_gender_privacy, { all_members: 0, women_only: 1, men_only: 2 }, prefix: true

  # Includes users who accepted an invitation OR were created manually (no invitation token or accepted_at)
  scope :active_users, -> { kept.where.not(invitation_accepted_at: nil).or(kept.where(invitation_token: nil, invitation_accepted_at: nil)) }
  scope :search_by_name, ->(query, exclude:) {
    active_users
      .with_attached_avatar
      .where.not(id: exclude.id)
      .where("name LIKE ?", "%#{sanitize_sql_like(query.strip)}%")
      .order(:name)
      .limit(10)
  }
  # A "male cohort member" is a non-admin who belongs to at least one cohort
  # flagged as a men's cohort. Everyone else — women's-cohort members, users with
  # no cohort at all, and every admin — counts as a female cohort member.
  # Expressed as subqueries so callers never iterate users in Ruby.
  scope :in_mens_cohort, -> {
    where(id: CohortMembership.joins(:cohort)
                              .where(cohorts: { mens_cohort: true, discarded_at: nil })
                              .select(:user_id))
  }
  scope :male_cohort_members, -> { attendee.in_mens_cohort }
  scope :female_cohort_members, -> { where.not(id: male_cohort_members.select(:id)) }
  scope :mentionable_in, ->(context) {
    case context
    when :cohort, :group
      where(mention_privacy: [ :groups_and_cohorts, :everywhere ])
    when :feed, :dm
      where(mention_privacy: :everywhere)
    else
      none
    end
  }

  belongs_to :bulk_invitation, optional: true

  has_many :cohort_memberships, dependent: :destroy
  has_many :cohorts, -> { kept }, through: :cohort_memberships
  has_many :posts, dependent: :destroy
  has_many :post_comments, dependent: :destroy
  has_many :post_reads, dependent: :destroy
  has_many :created_cohorts, class_name: "Cohort", foreign_key: :created_by_id, dependent: :nullify, inverse_of: :creator
  has_many :faqs, foreign_key: :created_by_id, dependent: :nullify, inverse_of: :creator

  has_many :group_memberships, dependent: :destroy
  has_many :groups, -> { kept }, through: :group_memberships
  has_many :group_posts, dependent: :destroy
  has_many :group_post_comments, dependent: :destroy
  has_many :group_post_reads, dependent: :destroy
  has_many :created_groups, class_name: "Group", foreign_key: :created_by_id, dependent: :nullify, inverse_of: :creator

  has_many :feed_posts, dependent: :destroy
  has_many :feed_post_comments, dependent: :destroy
  has_many :feed_post_reads, dependent: :destroy

  has_many :push_subscriptions, dependent: :destroy
  has_many :conversation_participants, dependent: :destroy
  has_many :conversations, through: :conversation_participants
  has_many :sent_direct_messages, class_name: "DirectMessage", foreign_key: :sender_id, dependent: :destroy, inverse_of: :sender

  has_many :notifications, dependent: :destroy
  has_many :mentions, dependent: :destroy
  has_many :created_mentions, class_name: "Mention", foreign_key: :mentioner_id, dependent: :destroy, inverse_of: :mentioner
  has_many :reactions, dependent: :destroy
  has_many :help_requests, dependent: :destroy
  has_many :help_request_replies, dependent: :destroy

  has_many :user_blocks, foreign_key: :blocker_id, dependent: :destroy, inverse_of: :blocker
  has_many :blocked_users, through: :user_blocks, source: :blocked
  # Ensures UserBlock records are destroyed when this user is the blocked party (not just the blocker).
  has_many :blocked_by_blocks, class_name: "UserBlock", foreign_key: :blocked_id, dependent: :destroy, inverse_of: :blocked

  has_one_attached :avatar do |attachable|
    attachable.variant :display, resize_to_fill: [ 200, 200 ]
  end

  after_invitation_accepted :create_invited_cohort_memberships
  after_invitation_accepted :notify_admins_of_acceptance

  geocoded_by :full_location
  after_commit :enqueue_geocode, if: -> { saved_change_to_city? || saved_change_to_state? || saved_change_to_country? }

  validates :name, presence: true
  validate :acceptable_avatar
  # Only on change: a later cohort membership change can invalidate a setting
  # that was legitimate when chosen, and that must not block unrelated saves.
  validate :cohort_gender_privacy_keeps_own_side, if: :cohort_gender_privacy_changed?

  def full_location
    [ city, state, country ].compact.join(", ")
  end

  def visible_location
    full_location if show_on_map
  end

  # True only when the avatar is attached AND its blob is persisted. After a
  # failed update the form re-renders with the just-uploaded (but unsaved)
  # avatar still attached in memory; generating a URL or variant for that new
  # blob raises "Cannot get a signed_id for a new record", so views must guard
  # avatar rendering with this rather than a bare `avatar.attached?`.
  def avatar_displayable?
    avatar.attached? && avatar.blob&.persisted?
  end

  def active_for_authentication?
    super && !discarded?
  end

  def inactive_message
    discarded? ? :account_removed : super
  end

  # Deliver Devise emails (invitation, password reset, etc.) asynchronously
  # so SMTP timeouts don't cause 500 errors during requests.
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def total_unread_count
    notifications.unread.count
  end

  def accepts_mentions_in?(context)
    return false if context.nil?

    case mention_privacy
    when "everywhere"
      true
    when "groups_and_cohorts"
      context.in?(%i[group cohort])
    when "nobody"
      false
    end
  end

  def email_enabled_for?(event_type)
    return false unless email_notifications_enabled?

    case event_type
    when "mention" then email_on_mention?
    when "direct_message" then email_on_direct_message?
    when "new_comment" then email_on_new_comment?
    when "new_post" then email_on_new_post?
    when "help_request_reply" then true
    else false
    end
  end

  # The group that sorts immediately after the given group in this user's
  # alphabetical list of groups, or nil if it sorts last.
  def group_following(group)
    groups.order(:name).where("name > ?", group.name).first
  end

  def blocks?(other_user)
    blocked_user_ids.include?(other_user.id)
  end

  def blocked_user_ids
    @blocked_user_ids ||= user_blocks.pluck(:blocked_id)
  end

  # Ids of users who have blocked this user.
  def blocked_by_user_ids
    @blocked_by_user_ids ||= blocked_by_blocks.pluck(:blocker_id)
  end

  # Admins are never classified as male cohort members: their content stays
  # visible to everyone regardless of the cohort gender preference, the same way
  # they cannot be blocked (see UserBlock).
  def male_cohort_member?
    return false if admin?
    return @male_cohort_member if defined?(@male_cohort_member)

    @male_cohort_member = cohorts.exists?(mens_cohort: true)
  end

  def female_cohort_member?
    !male_cohort_member?
  end

  # A member may exclude the other side of the community, but never their own.
  # The setting is validated on change, but a later cohort membership change can
  # strand an already-valid choice (a woman who joins a men's cohort keeps her
  # women_only setting), so reading it always goes through here.
  def effective_cohort_gender_privacy
    return "all_members" if cohort_gender_privacy_men_only? && female_cohort_member?
    return "all_members" if cohort_gender_privacy_women_only? && male_cohort_member?

    cohort_gender_privacy
  end

  # Ids of users whose content is hidden from this user by the cohort gender
  # preference. Mutual, exactly like blocking: it applies when this user's
  # setting excludes the other's side of the community, OR when the other's
  # setting excludes this user's side. Admins are absent from both candidate
  # sets, so admin-authored content is never hidden.
  #
  # The costliest case is a men_only viewer, where the excluded set is nearly the
  # whole attendee table: one indexed SELECT id, plucked once per request. If the
  # user table ever outgrows that, split Blockable#visible_to into two predicates
  # and keep this side as a subquery relation instead of an array.
  def cohort_gender_hidden_user_ids
    return @cohort_gender_hidden_user_ids if defined?(@cohort_gender_hidden_user_ids)

    excluded_by_me =
      case effective_cohort_gender_privacy
      when "women_only" then User.male_cohort_members
      when "men_only" then User.female_cohort_members.attendee
      else User.none
      end

    # Nobody's preference can hide their content from an admin — admins are
    # outside this filter in both directions, and only their own setting (above)
    # narrows what they see. Each set is restricted to members the setting is
    # valid for, mirroring effective_cohort_gender_privacy from the other side.
    excluding_me =
      if admin?
        User.none
      elsif male_cohort_member?
        User.female_cohort_members.attendee.where(cohort_gender_privacy: :women_only)
      else
        User.male_cohort_members.where(cohort_gender_privacy: :men_only)
      end

    # Subtract self, belt and braces: no valid setting can put a user in their
    # own excluded set.
    @cohort_gender_hidden_user_ids =
      (excluded_by_me.pluck(:id) + excluding_me.pluck(:id)).uniq - [ id ]
  end

  # Ids of users whose content is hidden from this user, for any reason: a block
  # in either direction, or a cohort gender preference on either side. Every
  # content surface funnels through here (Blockable#visible_to, UserPolicy::Scope,
  # CreateNotificationJob, mention autocomplete and rendering), so a new hiding
  # rule only has to be added in one place.
  def hidden_content_user_ids
    @hidden_content_user_ids ||=
      (blocked_user_ids + blocked_by_user_ids + cohort_gender_hidden_user_ids).uniq
  end

  def accepts_direct_messages_from?(sender)
    return false if blocks?(sender) || sender.blocks?(self)
    return true if sender.admin?
    # Blocking overrides admins (above); the cohort gender filter never does.
    return false if hidden_content_user_ids.include?(sender.id)

    case dm_privacy
    when "everyone"
      true
    when "cohort_members"
      (cohort_ids & sender.cohort_ids).any?
    when "nobody"
      false
    end
  end

  private

  def create_invited_cohort_memberships
    return if invited_cohort_ids.blank?

    Cohort.kept.where(id: invited_cohort_ids).find_each do |cohort|
      cohort_memberships.create(cohort: cohort)
    end

    update_column(:invited_cohort_ids, nil)
  end

  def notify_admins_of_acceptance
    User.admin.where.not(id: id).pluck(:id).each do |admin_id|
      CreateNotificationJob.perform_later(
        user_id: admin_id,
        actor_id: id,
        event_type: "new_member",
        title: "New Member",
        body: "#{name} has joined the community",
        path: "/profiles/#{id}"
      )
    end
  end

  def enqueue_geocode
    GeocodeUserJob.perform_later(id)
  end

  # Members can filter out the other side of the community, never their own.
  def cohort_gender_privacy_keeps_own_side
    if cohort_gender_privacy_men_only? && female_cohort_member?
      errors.add(:cohort_gender_privacy, "can't hide female cohort members' content while you are one")
    elsif cohort_gender_privacy_women_only? && male_cohort_member?
      errors.add(:cohort_gender_privacy, "can't hide male cohort members' content while you are one")
    end
  end

  def acceptable_avatar
    return unless avatar.attached?
    unless avatar.blob.content_type.in?(%w[image/jpeg image/png image/gif image/webp])
      errors.add(:avatar, "must be a JPEG, PNG, GIF, or WebP")
    end
    if avatar.blob.byte_size > 5.megabytes
      errors.add(:avatar, "must be less than 5MB")
    end
  end
end
