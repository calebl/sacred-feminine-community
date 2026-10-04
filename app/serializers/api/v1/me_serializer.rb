module Api
  module V1
    # The signed-in member's own profile: the public shape plus the private
    # settings and counts only they may see.
    class MeSerializer
      def initialize(user)
        @user = user
      end

      def as_json(*)
        UserSerializer.new(@user).as_json.merge(
          email: @user.email,
          city: @user.city,
          state: @user.state,
          country: @user.country,
          show_on_map: @user.show_on_map,
          dm_privacy: @user.dm_privacy,
          mention_privacy: @user.mention_privacy,
          cohort_gender_privacy: @user.cohort_gender_privacy,
          unread_notification_count: @user.total_unread_count
        )
      end
    end
  end
end
