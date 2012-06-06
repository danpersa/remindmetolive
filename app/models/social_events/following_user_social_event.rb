class FollowingUserSocialEvent < SocialEvent
  include Mongoid::Document

  field :users_count,  type: Integer, default: 1
  field :first_users_count,  type: Integer, default: 1

  has_and_belongs_to_many :first_users, :class_name => 'User'
  has_and_belongs_to_many :users

  class << self
    alias old_create! create!
  end

  def self.created_by_user_today_with_following user, following
    today = Time.now.utc
    start_time = self.start_of_day today
    end_time = self.end_of_day today
    FollowingUserSocialEvent.where({:created_at => {'$gte' => start_time,'$lt' => end_time},
                                    :created_by_id => user.id,
                                    :user_ids => {'$in' => [following.id]}})
                            .first
  end

  def self.created_by_user_today user
    today = Time.now.utc
    start_time = self.start_of_day today
    end_time = self.end_of_day today
    FollowingUserSocialEvent.where({:created_at => {'$gte' => start_time,'$lt' => end_time},
                                    :created_by_id => user.id})
                            .first
  end

  def self.create! created_by, following
    event_created_today_by_user = FollowingUserSocialEvent.created_by_user_today created_by
    unless event_created_today_by_user
      return FollowingUserSocialEvent.old_create! :created_by => created_by,
                                                  :users => [following],
                                                  :first_users => [following]
    else
      created_by_user_today_with_following = self.created_by_user_today_with_following created_by, following
      unless created_by_user_today_with_following
        if event_created_today_by_user.first_users_count < MAX_FIRST_USERS
          event_created_today_by_user.push_with_first_user following
        else
          event_created_today_by_user.push_user following
        end
      end
    end
    return event_created_today_by_user
  end

  def self.unfollow! created_by, unfollowed
    social_events = self.where(:created_by_id => created_by.id).entries
    social_events.each do |social_event|
      social_event.remove_user unfollowed
    end
  end

end
