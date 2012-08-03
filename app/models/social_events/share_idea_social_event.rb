class ShareIdeaSocialEvent < IdeaSocialEvent
  include Mongoid::Document

  field :users_count,  type: Integer, default: 1
  field :first_users_count,  type: Integer, default: 1

  has_and_belongs_to_many :first_users, :class_name => 'User'
  has_and_belongs_to_many :users


  class << self
    alias old_create! create!
  end

  def self.create! shared_by, idea
    event_created_today_for_idea = self.for_idea_created_today idea
    unless event_created_today_for_idea
      return self.old_create! :created_by => idea.created_by,
                              :users => [shared_by],
                              :first_users => [shared_by],
                              :idea => idea
    else
      event_created_today_for_idea_by_user = self.for_idea_created_today_by idea, shared_by
      unless event_created_today_for_idea_by_user
        if event_created_today_for_idea.first_users_count < MAX_FIRST_USERS
          self.collection.update(
          	{:_id => event_created_today_for_idea.id},
          	{:$addToSet => {:first_user_ids => shared_by.id, :user_ids => shared_by.id},
          	 :$inc => {:first_users_count => 1, :users_count => 1}})
        else
          self.collection.update(
          	{:_id => event_created_today_for_idea.id},
          	{:$addToSet => {:user_ids => shared_by.id},
          	 :$inc => {:users_count => 1}})
        end
      end
    end
    return event_created_today_for_idea
  end

  def self.for_idea_created_today idea
  	today = Time.now.utc
    start_time = self.start_of_day today
    end_time = self.end_of_day today
    self.where({:created_at => {'$gte' => start_time,'$lt' => end_time},
                :idea_id => idea.id}).first
  end

  def self.for_idea_created_today_by idea, shared_by
  	today = Time.now.utc
    start_time = self.start_of_day today
    end_time = self.end_of_day today
    self.where({:created_at => {'$gte' => start_time,'$lt' => end_time},
                 :idea_id => idea.id,
                 :user_ids => {'$in' => [shared_by.id]}
              }).first
  end
end
