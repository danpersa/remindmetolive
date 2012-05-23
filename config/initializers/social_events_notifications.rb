# idea related notifications
ActiveSupport::Notifications.subscribe SocialEventNotification::Values[:idea][:created] do |name, start, finish, id, payload|
  if RemindMeToLive::Application.config.enable_social_event_notifications
    Rails.logger.debug "The user : #{payload[:created_by].display_name} has created an idea with the content: #{payload[:idea].content}"
    #puts "The User : #{payload[:created_by].display_name} has created an idea with the content: #{payload[:idea].content}"
    CreateIdeaSocialEvent.create! :created_by => payload[:created_by], :idea => payload[:idea]
  end
end

ActiveSupport::Notifications.subscribe SocialEventNotification::Values[:idea][:shared] do |name, start, finish, id, payload|
  if RemindMeToLive::Application.config.enable_social_event_notifications
    Rails.logger.debug "The user : #{payload[:shared_by].display_name} has shared an idea with the content: #{payload[:idea].content}"
    ShareIdeaSocialEvent.create! payload[:shared_by], payload[:idea]
  end
end

ActiveSupport::Notifications.subscribe SocialEventNotification::Values[:idea][:unshared] do |name, start, finish, id, payload|
  if RemindMeToLive::Application.config.enable_social_event_notifications
    #ShareIdeaSocialEvent.create! :created_by => payload[:created_by], :idea => payload[:idea]
  end
end

ActiveSupport::Notifications.subscribe SocialEventNotification::Values[:idea][:done] do |name, start, finish, id, payload|
  if RemindMeToLive::Application.config.enable_social_event_notifications
    DoneIdeaSocialEvent.create! :created_by => payload[:created_by], :idea => payload[:idea]
  end
end

ActiveSupport::Notifications.subscribe SocialEventNotification::Values[:idea][:undone] do |name, start, finish, id, payload|
  if RemindMeToLive::Application.config.enable_social_event_notifications
    DoneIdeaSocialEvent.where(:created_by_id => payload[:created_by].id,
                            :idea_id => payload[:idea].id)
                       .destroy_all
  end                         
end

ActiveSupport::Notifications.subscribe SocialEventNotification::Values[:idea][:good] do |name, start, finish, id, payload|
  if RemindMeToLive::Application.config.enable_social_event_notifications
    GoodIdeaSocialEvent.create! :created_by => payload[:created_by],
                                :idea => payload[:idea]
  end
end

ActiveSupport::Notifications.subscribe SocialEventNotification::Values[:idea][:ungood] do |name, start, finish, id, payload|
  if RemindMeToLive::Application.config.enable_social_event_notifications
    GoodIdeaSocialEvent.where(:created_by_id => payload[:created_by].id,
                              :idea_id => payload[:idea].id)
                       .destroy_all
  end
end

# user related notifications
ActiveSupport::Notifications.subscribe SocialEventNotification::Values[:user][:following] do |name, start, finish, id, payload|
  if RemindMeToLive::Application.config.enable_social_event_notifications
    FollowingUserSocialEvent.create! payload[:created_by], payload[:following]
  end
end

ActiveSupport::Notifications.subscribe SocialEventNotification::Values[:user][:followed] do |name, start, finish, id, payload|
  if RemindMeToLive::Application.config.enable_social_event_notifications
    #FollowedUserSocialEvent.create! :created_by => payload[:created_by],
    #                                :user => payload[:followed]
  end
end

ActiveSupport::Notifications.subscribe SocialEventNotification::Values[:user][:unfollowed] do |name, start, finish, id, payload|
  if RemindMeToLive::Application.config.enable_social_event_notifications
    FollowingUserSocialEvent.unfollow! payload[:created_by], payload[:unfollowed]
  end
end