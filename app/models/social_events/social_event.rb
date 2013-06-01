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
    self.pull_user user
  rescue Mongoid::Errors::DocumentNotFound
    return nil
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
end
