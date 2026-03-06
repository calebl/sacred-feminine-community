# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_07_015156) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "announcements", force: :cascade do |t|
    t.boolean "active", default: false, null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.datetime "published_at"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_announcements_on_active"
    t.index ["created_by_id"], name: "index_announcements_on_created_by_id"
  end

  create_table "audits", force: :cascade do |t|
    t.string "action"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "auditable_id"
    t.string "auditable_type"
    t.json "audited_changes"
    t.string "comment"
    t.datetime "created_at"
    t.string "remote_address"
    t.string "request_uuid"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.integer "version", default: 0
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "chat_messages", force: :cascade do |t|
    t.text "body", null: false
    t.integer "cohort_id", null: false
    t.datetime "created_at", null: false
    t.boolean "system_message", default: false, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["cohort_id", "created_at"], name: "index_chat_messages_on_cohort_id_and_created_at"
    t.index ["cohort_id"], name: "index_chat_messages_on_cohort_id"
    t.index ["user_id"], name: "index_chat_messages_on_user_id"
  end

  create_table "cohort_memberships", force: :cascade do |t|
    t.integer "cohort_id", null: false
    t.datetime "created_at", null: false
    t.datetime "joined_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "last_read_at"
    t.datetime "posts_last_read_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["cohort_id"], name: "index_cohort_memberships_on_cohort_id"
    t.index ["user_id", "cohort_id"], name: "index_cohort_memberships_on_user_id_and_cohort_id", unique: true
    t.index ["user_id"], name: "index_cohort_memberships_on_user_id"
  end

  create_table "cohorts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.string "name", null: false
    t.date "retreat_end_date"
    t.string "retreat_location"
    t.date "retreat_start_date"
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_cohorts_on_created_by_id"
    t.index ["discarded_at"], name: "index_cohorts_on_discarded_at"
  end

  create_table "conversation_participants", force: :cascade do |t|
    t.integer "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "last_read_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["conversation_id", "user_id"], name: "index_conversation_participants_on_conversation_id_and_user_id", unique: true
    t.index ["conversation_id"], name: "index_conversation_participants_on_conversation_id"
    t.index ["user_id"], name: "index_conversation_participants_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "direct_messages", force: :cascade do |t|
    t.text "body", null: false
    t.integer "conversation_id", null: false
    t.datetime "created_at", null: false
    t.integer "sender_id", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "created_at"], name: "index_direct_messages_on_conversation_id_and_created_at"
    t.index ["conversation_id"], name: "index_direct_messages_on_conversation_id"
    t.index ["sender_id"], name: "index_direct_messages_on_sender_id"
  end

  create_table "faqs", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.text "answer", null: false
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.integer "position", default: 0, null: false
    t.string "question", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_faqs_on_active"
    t.index ["created_by_id"], name: "index_faqs_on_created_by_id"
  end

  create_table "feed_post_comments", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.integer "feed_post_id", null: false
    t.integer "parent_id"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["feed_post_id"], name: "index_feed_post_comments_on_feed_post_id"
    t.index ["parent_id"], name: "index_feed_post_comments_on_parent_id"
    t.index ["user_id"], name: "index_feed_post_comments_on_user_id"
  end

  create_table "feed_post_reads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "feed_post_id", null: false
    t.datetime "last_read_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["feed_post_id"], name: "index_feed_post_reads_on_feed_post_id"
    t.index ["user_id", "feed_post_id"], name: "index_feed_post_reads_on_user_and_post", unique: true
    t.index ["user_id"], name: "index_feed_post_reads_on_user_id"
  end

  create_table "feed_posts", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.boolean "pinned", default: false, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["pinned", "created_at"], name: "index_feed_posts_on_pinned_created"
    t.index ["user_id"], name: "index_feed_posts_on_user_id"
  end

  create_table "group_chat_messages", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.integer "group_id", null: false
    t.boolean "system_message", default: false, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["group_id", "created_at"], name: "index_group_chat_messages_on_group_id_and_created_at"
    t.index ["group_id"], name: "index_group_chat_messages_on_group_id"
    t.index ["user_id"], name: "index_group_chat_messages_on_user_id"
  end

  create_table "group_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "group_id", null: false
    t.datetime "joined_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "last_read_at"
    t.datetime "posts_last_read_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
    t.index ["user_id", "group_id"], name: "index_group_memberships_on_user_id_and_group_id", unique: true
    t.index ["user_id"], name: "index_group_memberships_on_user_id"
  end

  create_table "group_post_comments", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.integer "group_post_id", null: false
    t.integer "parent_id"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["group_post_id"], name: "index_group_post_comments_on_group_post_id"
    t.index ["parent_id"], name: "index_group_post_comments_on_parent_id"
    t.index ["user_id"], name: "index_group_post_comments_on_user_id"
  end

  create_table "group_post_reads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "group_post_id", null: false
    t.datetime "last_read_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["group_post_id"], name: "index_group_post_reads_on_group_post_id"
    t.index ["user_id", "group_post_id"], name: "index_group_post_reads_on_user_and_post", unique: true
    t.index ["user_id"], name: "index_group_post_reads_on_user_id"
  end

  create_table "group_posts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "group_id", null: false
    t.boolean "pinned", default: false, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["group_id", "pinned", "created_at"], name: "index_group_posts_on_group_pinned_created"
    t.index ["group_id"], name: "index_group_posts_on_group_id"
    t.index ["user_id"], name: "index_group_posts_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_groups_on_created_by_id"
    t.index ["discarded_at"], name: "index_groups_on_discarded_at"
  end

  create_table "mentions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "mentionable_id", null: false
    t.string "mentionable_type", null: false
    t.integer "mentioner_id", null: false
    t.datetime "read_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["mentionable_type", "mentionable_id", "user_id"], name: "index_mentions_on_mentionable_and_user", unique: true
    t.index ["mentionable_type", "mentionable_id"], name: "index_mentions_on_mentionable"
    t.index ["mentioner_id"], name: "index_mentions_on_mentioner_id"
    t.index ["user_id", "read_at"], name: "index_mentions_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_mentions_on_user_id"
  end

  create_table "post_comments", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.integer "parent_id"
    t.integer "post_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["parent_id"], name: "index_post_comments_on_parent_id"
    t.index ["post_id"], name: "index_post_comments_on_post_id"
    t.index ["user_id"], name: "index_post_comments_on_user_id"
  end

  create_table "post_reads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_read_at"
    t.integer "post_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["post_id"], name: "index_post_reads_on_post_id"
    t.index ["user_id", "post_id"], name: "index_post_reads_on_user_id_and_post_id", unique: true
    t.index ["user_id"], name: "index_post_reads_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.text "body"
    t.integer "cohort_id", null: false
    t.datetime "created_at", null: false
    t.boolean "pinned", default: false, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["cohort_id", "pinned", "created_at"], name: "index_posts_on_cohort_pinned_created"
    t.index ["cohort_id"], name: "index_posts_on_cohort_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "push_subscriptions", force: :cascade do |t|
    t.string "auth_key", null: false
    t.datetime "created_at", null: false
    t.string "endpoint", null: false
    t.string "p256dh_key", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["endpoint"], name: "index_push_subscriptions_on_endpoint", unique: true
    t.index ["user_id"], name: "index_push_subscriptions_on_user_id"
  end

  create_table "reactions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "emoji", null: false
    t.integer "reactable_id", null: false
    t.string "reactable_type", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["reactable_type", "reactable_id", "emoji"], name: "index_reactions_on_reactable_and_emoji"
    t.index ["reactable_type", "reactable_id", "user_id"], name: "index_reactions_on_reactable_and_user", unique: true
    t.index ["reactable_type", "reactable_id"], name: "index_reactions_on_reactable"
    t.index ["user_id"], name: "index_reactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "bio"
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.boolean "dm_notifications", default: true, null: false
    t.integer "dm_privacy", default: 1, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "invitation_accepted_at"
    t.datetime "invitation_created_at"
    t.integer "invitation_limit"
    t.datetime "invitation_sent_at"
    t.string "invitation_token"
    t.integer "invitations_count", default: 0
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.text "invited_cohort_ids"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.integer "mention_privacy", default: 2, null: false
    t.string "name", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.boolean "show_on_map", default: false, null: false
    t.string "state"
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["latitude", "longitude"], name: "index_users_on_latitude_and_longitude"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "announcements", "users", column: "created_by_id"
  add_foreign_key "chat_messages", "cohorts"
  add_foreign_key "chat_messages", "users"
  add_foreign_key "cohort_memberships", "cohorts"
  add_foreign_key "cohort_memberships", "users"
  add_foreign_key "cohorts", "users", column: "created_by_id"
  add_foreign_key "conversation_participants", "conversations"
  add_foreign_key "conversation_participants", "users"
  add_foreign_key "direct_messages", "conversations"
  add_foreign_key "direct_messages", "users", column: "sender_id"
  add_foreign_key "faqs", "users", column: "created_by_id"
  add_foreign_key "feed_post_comments", "feed_post_comments", column: "parent_id"
  add_foreign_key "feed_post_comments", "feed_posts"
  add_foreign_key "feed_post_comments", "users"
  add_foreign_key "feed_post_reads", "feed_posts"
  add_foreign_key "feed_post_reads", "users"
  add_foreign_key "feed_posts", "users"
  add_foreign_key "group_chat_messages", "groups"
  add_foreign_key "group_chat_messages", "users"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "users"
  add_foreign_key "group_post_comments", "group_post_comments", column: "parent_id"
  add_foreign_key "group_post_comments", "group_posts"
  add_foreign_key "group_post_comments", "users"
  add_foreign_key "group_post_reads", "group_posts"
  add_foreign_key "group_post_reads", "users"
  add_foreign_key "group_posts", "groups"
  add_foreign_key "group_posts", "users"
  add_foreign_key "groups", "users", column: "created_by_id"
  add_foreign_key "mentions", "users"
  add_foreign_key "mentions", "users", column: "mentioner_id"
  add_foreign_key "post_comments", "post_comments", column: "parent_id"
  add_foreign_key "post_comments", "posts"
  add_foreign_key "post_comments", "users"
  add_foreign_key "post_reads", "posts"
  add_foreign_key "post_reads", "users"
  add_foreign_key "posts", "cohorts"
  add_foreign_key "posts", "users"
  add_foreign_key "push_subscriptions", "users"
  add_foreign_key "reactions", "users"
end
