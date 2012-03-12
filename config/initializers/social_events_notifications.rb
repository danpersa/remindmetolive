if RemindMeToLive::Application.config.enable_social_event_notifications

  # idea related notifications
  ActiveSupport::Notifications.subscribe SocialEventNotification::Values[:idea][:created] do |name, start, finish, id, payload|
    #Rails.logger.debug "The User : #{payload[:created_by].display_name} has created an idea with the content: #{payload[:idea].content}"
    CreateIdeaSocialEvent.create! :created_by => payload[:created_by], :idea => payload[:idea]
  end

  ActiveSupport::Notifications.subscribe SocialEventNotification::Values[:idea][:done] do |name, start, finish, id, payload|
    DoneIdeaSocialEvent.create! :created_by => payload[:created_by], :idea => payload[:idea]
  end

  ActiveSupport::Notifications.subscribe SocialEventNotification::Values[:idea][:good] do |name, start, finish, id, payload|
    GoodIdeaSocialEvent.create! :created_by => payload[:created_by], :idea => payload[:idea]
  end

  # user related notifications
  ActiveSupport::Notifications.subscribe SocialEventNotification::Values[:user][:following] do |name, start, finish, id, payload|
    FollowingUserSocialEvent.create! payload[:created_by], payload[:following]
  end

  ActiveSupport::Notifications.subscribe SocialEventNotification::Values[:user][:followed] do |name, start, finish, id, payload|
    FollowedUserSocialEvent.create! :created_by => payload[:created_by], :user => payload[:followed]
  end

  ActiveSupport::Notifications.subscribe SocialEventNotification::Values[:user][:unfollowed] do |name, start, finish, id, payload|
    
  end

end