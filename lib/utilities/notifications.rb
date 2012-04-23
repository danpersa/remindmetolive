
module RemindMeToLive
  module Notifications

    def user_is_following_notification user, followed
      ActiveSupport::Notifications.instrument(
          SocialEventNotification::Values[:user][:following],
          :created_by => user, :following => followed)
    end

    def user_is_followed_notification user, followed
      ActiveSupport::Notifications.instrument(
          SocialEventNotification::Values[:user][:followed],
          :created_by => user, :following => followed)
    end

    def user_has_unfollowed_notification user, unfollowed
      ActiveSupport::Notifications.instrument(
          SocialEventNotification::Values[:user][:unfollowed],
          :created_by => user, :unfollowed => unfollowed)
    end

    def user_creates_idea_notification user, idea
      ActiveSupport::Notifications.instrument(
          SocialEventNotification::Values[:idea][:created],
          :created_by => user, :idea => idea)
    end

    def user_marks_idea_as_good_notification user, idea
      ActiveSupport::Notifications.instrument(
          SocialEventNotification::Values[:idea][:good],
          :created_by => user, :idea => idea)
    end

    def user_unmarks_idea_as_good_notification user, idea
      ActiveSupport::Notifications.instrument(
          SocialEventNotification::Values[:idea][:ungood],
          :created_by => user, :idea => idea)
    end

    def user_unmarks_idea_as_done_notification user, idea
      ActiveSupport::Notifications.instrument(
          SocialEventNotification::Values[:idea][:undone],
          :created_by => user, :idea => idea)
    end

    def user_marks_idea_as_done_notification user, idea
      ActiveSupport::Notifications.instrument(
         SocialEventNotification::Values[:idea][:done],
         :created_by => user, :idea => idea)
    end
  end
end
