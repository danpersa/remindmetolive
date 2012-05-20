class SocialEvent
  include Mongoid::Document
  include Mongoid::Timestamps

  MAX_FIRST_USERS = 3
  SECONDS_PER_DAY = 86_400

  field :privacy,                  :type => Integer, :default => 0

  belongs_to :created_by, :class_name => 'User'

  index :created_at
  index :updated_at
  index :created_by_id
  index :user_ids

  validates_inclusion_of      :privacy, in: [Privacy::Values[:public], Privacy::Values[:private]]

  # all the public social events of the users followed by the user
  def self.public_of_users_followed_by user
    following_ids = user.following_ids
    SocialEvent.all_of(:created_by_id.in => following_ids, :privacy => Privacy::Values[:public]).desc(:updated_at)
  end

  def self.own_or_public_of_users_followed_by user
    following_ids = user.following_ids
    SocialEvent.any_of({:created_by_id.in => following_ids, :privacy => Privacy::Values[:public]}, {:created_by_id => user.id}).desc(:updated_at)
  end

  def self.of_user user
    SocialEvent.any_of({:created_by_id => user.id}, {:user_ids.in => [user.id]}).desc(:updated_at)
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

end
