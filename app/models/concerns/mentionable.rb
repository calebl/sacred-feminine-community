module Mentionable
  extend ActiveSupport::Concern

  MENTION_PATTERN = /@\[([^\]]+)\]\((\d+)\)/

  included do
    has_many :mentions, as: :mentionable, dependent: :destroy
    after_create_commit :extract_mentions
  end

  private

  def extract_mentions
    return if body.blank?

    mentioned_user_ids = body.scan(MENTION_PATTERN).map { |_name, id| id.to_i }.uniq
    return if mentioned_user_ids.empty?

    author = mention_author
    valid_users = User.active_users.where(id: mentioned_user_ids).where.not(id: author.id)

    valid_users.find_each do |user|
      mentions.create(user: user, mentioner: author)
    end
  end

  def mention_author
    respond_to?(:sender) ? sender : user
  end
end
