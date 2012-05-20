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
    FollowingUserSocialEvent.first(:conditions => 
                                   {:created_at => {'$gte' => start_time,'$lt' => end_time},
                                    :created_by_id => user.id,
                                    :user_ids => {'$in' => [following.id]}})
  end

  def self.created_by_user_today user
    today = Time.now.utc
    start_time = self.start_of_day today
    end_time = self.end_of_day today
    FollowingUserSocialEvent.first(:conditions => 
                                   {:created_at => {'$gte' => start_time,'$lt' => end_time},
                                    :created_by_id => user.id})
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
          FollowingUserSocialEvent.collection.update(
            {:_id => event_created_today_by_user.id}, 
            {:$addToSet => {:first_user_ids => following.id, :user_ids => following.id},
             :$inc => {:first_users_count => 1, :users_count => 1}
            })
        else
          FollowingUserSocialEvent.collection.update(
            {:_id => event_created_today_by_user.id}, 
            {:$addToSet => {:user_ids => following.id}, 
             :$inc => {:users_count => 1}
            })
        end
      end
    end
    return event_created_today_by_user
  end

  def remove_user followed
    self.users.find(followed.id) # should rise the error
    self.destroy and return if self.users_count == 1

    if (self.first_users.include? followed)
      FollowingUserSocialEvent.collection.update({:_id => self.id}, {:$pull => {:first_user_ids => followed.id, :user_ids => followed.id}, :$inc => {:first_users_count => -1, :users_count => -1}})
    else
      FollowingUserSocialEvent.collection.update({:_id => self.id}, {:$pull => {:user_ids => followed.id}, :$inc => {:users_count => -1}})
    end
    repopulate_first_users self.id
  rescue Mongoid::Errors::DocumentNotFound
    return nil
  end

  private

  def repopulate_first_users following_event_id
    following_event = FollowingUserSocialEvent.find(following_event_id)
    if following_event.first_users_count < MAX_FIRST_USERS and following_event.users_count > following_event.first_users_count
      user = following_event.users.not_in(:_id => following_event.first_user_ids).first
      FollowingUserSocialEvent.collection.update({:_id => following_event_id}, {:$addToSet => {:first_user_ids => user.id}, :$inc => {:first_users_count => 1}})
    end
  end
end
