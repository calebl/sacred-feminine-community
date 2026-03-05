class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def show
    skip_authorization

    @conversations = policy_scope(Conversation)
                       .includes(:participants, :conversation_participants, direct_messages: :sender)
                       .order(updated_at: :desc)

    @cohorts = policy_scope(Cohort)
                 .includes(:cohort_memberships, :chat_messages, :posts)
                 .order(:name)

    @unread_conversations = @conversations.select { |c| c.unread_count(current_user) > 0 }
    @unread_cohorts = @cohorts.select { |c| c.unread_count(current_user) > 0 }
    @unread_post_cohorts = @cohorts.select { |c| c.unread_post_count(current_user) > 0 }

    # Posts where the user has commented and there are new comments from others
    commented_post_ids = current_user.post_comments.select(:post_id).distinct
    @unread_comment_posts = Post.where(id: commented_post_ids)
                                .includes(:post_comments, :post_reads, :user, :cohort)
                                .select { |p| p.unread_comment_count(current_user) > 0 }
  end
end
