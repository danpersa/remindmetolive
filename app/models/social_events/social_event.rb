class SocialEvent
  include Mongoid::Document
  include Mongoid::Timestamps

  MAX_FIRST_USERS = 3
  SECONDS_PER_DAY = 86_400

  field :privacy,                  :type => Integer, :default => 0

  belongs_to :created_by, :class_name => 'User'

  validates_inclusion_of      :privacy, in: [Privacy::Values[:public], Privacy::Values[:private]]

  # all the public social events of the users followed by the user
  def self.public_of_users_followed_by user
    following_ids = user.following_ids
    SocialEvent.any_of({:created_by_id.in => following_ids,
                        :privacy => Privacy::Values[:public]})
               .desc(:updated_at)
  end

  def self.own_or_public_of_users_followed_by user
    following_ids = user.following_ids
    SocialEvent.any_of({:created_by_id.in => following_ids,
                        :privacy => Privacy::Values[:public]},
                       {:created_by_id => user.id},
                       {:user_ids.in => [user.id]})
               .desc(:updated_at)
  end

  def self.of_user user
    SocialEvent.or({:user_ids.in => [user.id]}, {:created_by_id => user.id})
               .desc(:updated_at)
  end

  def self.public_of_user user
    self.of_user(user).where(:privacy => Privacy::Values[:public])
  end

  def self.start_of_day day
    Time.utc(day.year, day.month, day.day)
  end

  def self.end_of_day day
    Time.utc(day.year, day.month, day.day) +  1 * SECONDS_PER_DAY # we add one day
  end

  def remove_user user
    self.users.find(user.id) # should rise the error
    self.destroy and return if self.users_count == 1
    if (self.first_users.include? user)
      self.pull_with_first_user user
      repopulate_first_users self.id
    else
      self.pull_user user
    end
  rescue Mongoid::Errors::DocumentNotFound
    return nil
  end

  def repopulate_first_users following_event_id
    following_event = SocialEvent.find(following_event_id)
    if following_event.first_users_count < MAX_FIRST_USERS and following_event.users_count > following_event.first_users_count
      user = following_event.users.not_in(:_id => following_event.first_user_ids).first
      SocialEvent.where({:_id => following_event_id})
                 .find_and_modify({:$addToSet => {:first_user_ids => user.id}, :$inc => {:first_users_count => 1}})
    end
  end

  def push_user user
    SocialEvent.where({:_id => self.id})
               .find_and_modify({:$addToSet => {:user_ids => user.id},
                                 :$inc => {:users_count => 1}})
  end

  def pull_user user
    SocialEvent.where(:_id => self.id)
               .find_and_modify({:$pull => {:user_ids => user.id},
                                 :$inc => {:users_count => -1}})
  end

  def push_with_first_user user
    SocialEvent.where(:_id => self.id)
               .find_and_modify({:$addToSet => {:first_user_ids => user.id, :user_ids => user.id},
                                 :$inc => {:first_users_count => 1, :users_count => 1}})
  end

  def pull_with_first_user user
    SocialEvent.where(:_id => self.id)
               .find_and_modify({:$pull => {:first_user_ids => user.id, :user_ids => user.id},
                                 :$inc => {:first_users_count => -1, :users_count => -1}})
  end
end
