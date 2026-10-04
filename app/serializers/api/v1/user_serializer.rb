module Api
  module V1
    # The public shape of a member, as any other member may see it.
    class UserSerializer
      include Rails.application.routes.url_helpers

      def initialize(user)
        @user = user
      end

      def as_json(*)
        {
          id: @user.id,
          name: @user.name,
          role: @user.role,
          bio: @user.bio,
          location: @user.visible_location,
          avatar_path: avatar_path,
          removed: @user.discarded?
        }
      end

      private

      # Relative, so the app joins it to whichever server it signed in to. Uses
      # avatar_displayable? for the same reason the views do.
      def avatar_path
        return unless @user.avatar_displayable?

        rails_representation_path(@user.avatar.variant(:display), only_path: true)
      end
    end
  end
end
