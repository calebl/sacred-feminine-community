class GroupPost < ApplicationRecord
  include Mentionable
  include Reactable

  belongs_to :group
  belongs_to :user

  has_many :group_post_comments, dependent: :destroy
  has_many :group_post_reads, dependent: :destroy

  scope :pinned_first, -> { order(pinned: :desc, created_at: :desc) }

  validates :body, presence: true

  def mark_mentions_read(user)
    Mention.unread.where(user: user, mentionable: self).update_all(read_at: Time.current)
    Mention.unread.where(user: user, mentionable_type: "GroupPostComment", mentionable_id: group_post_comments.select(:id))
           .update_all(read_at: Time.current)
  end

  def unread_comment_count(user)
    post_read = group_post_reads.find_by(user: user)
    comments = group_post_comments.where.not(user: user)
    if post_read&.last_read_at
      comments.where("group_post_comments.created_at > ?", post_read.last_read_at).count
    else
      comments.count
    end
  end
end
