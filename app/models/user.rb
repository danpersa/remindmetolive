require 'mongoid/edge-state-machine'
require 'notifications'

class User < EdgeAuth::User
  extend RemindMeToLive::Notifications

  field :username                    , :type => String
  field :admin                       , :type => Boolean
  field :following_count             , :type => Integer, default: 0
  field :followers_count             , :type => Integer, default: 0
  field :idea_lists_count            , :type => Integer, default: 0


  has_and_belongs_to_many    :followers, class_name: 'User'
  has_and_belongs_to_many    :following, class_name: 'User'

  has_many :ideas, class_name: 'UserIdea', inverse_of: :user
  has_many :idea_lists

  embeds_one  :profile

  # index :username, unique: true

  #has_many :created_ideas, class_name: 'Idea', inverse_of: :created_by
  #has_many :owned_ideas,   class_name: 'Idea', inverse_of: :owned_by

  attr_accessor   :password, :updating_password
  attr_accessible :username, :email, :password, :password_confirmation, :activation_code

  validates_presence_of       :username
  validates_length_of         :username, minimum: 5, maximum: 25
  validates_uniqueness_of     :username

  # should only be called with pagination
  def ideas_ordered_by_reminder_created_at
    self.ideas.desc(:reminder_created_at)
  end

  # should only be called with pagination
  def ideas_from_list_ordered_by_reminder_created_at idea_list
    idea_ids = idea_list.idea_ids.entries
    self.ideas.where(:_id.in => idea_ids).desc(:reminder_created_at)
  end

  def idea_list_with_id id
    self.idea_lists.find(id)
  rescue Mongoid::Errors::DocumentNotFound
    return nil
  end

  def user_idea_for_idea idea
    self.ideas.where(:idea_id => idea.id).first
  end

  def following?(followed)
    self.following.include? followed
  end

  def follow!(followed)
    #return if self.following? followed
    self.push_following followed
    followed.push_follower self
    User.user_is_following_notification self, followed
  end

  def unfollow!(followed)
    self.following_count -= 1
    self.following.delete followed
    followed.followers_count -= 1
    followed.followers.delete self
    User.user_has_unfollowed_notification self, followed
  end

  def create_new_idea!(params)
    idea = Idea.new({:content    => params[:content],
                     :privacy    => params[:privacy],
                     :created_by => self,
                     :owned_by   => self})
    user_idea = UserIdea.new({:privacy => params[:privacy],
                              :reminder_date => params[:reminder_date],
                              :reminder_created_at => Time.now,
                              :idea => idea,
                              :user => self})
    if idea.valid? and user_idea.valid?
      idea.save!
      user_idea.save!
      User.user_creates_idea_notification self, idea
    end
    return user_idea
  end

  def create_user_idea! params
    user_idea = UserIdea.new({:privacy => params[:privacy],
                              :reminder_date => params[:reminder_date],
                              :reminder_created_at => Time.now,
                              :idea_id => params[:idea_id],
                              :user => self})
    if user_idea.valid?
      user_idea.save!
      user_idea.reload
      if user_idea.privacy == Privacy::Values[:public]
        User.user_shares_idea_notification self, user_idea.idea
      end
    else
      raise 'An error has occured'
    end
    return user_idea
  end

  def has_idea? idea
    self.ideas.where(:idea_id => idea.id).count > 0
  end

  def user_idea idea
    self.ideas.where(:idea_id => idea.id).first
  end

  def has_user_idea? user_idea
    self.ideas.where(:_id => user_idea.id).count > 0
  end

  def create_idea_list name
    idea_list = IdeaList.new :name => name
    idea_list.user = self
    if idea_list.valid?
      self.idea_lists_count += 1
      idea_list.save
    end
    return idea_list
  end

  def remove_idea_list idea_list
    idea_list = self.idea_lists.find(idea_list.id) # should raise an error
    self.idea_lists_count -= 1
    self.idea_lists.delete idea_list
    idea_list.destroy
    return self.save
  rescue Mongoid::Errors::DocumentNotFound
    return false
  end

  def set_reminder_to_idea!(idea_id, params)
    user_idea = self.ideas.find(idea_id)
    user_idea.set_reminder params[:reminder_date]
    user_idea.save!
  end

  def display_name
    unless self.profile.nil?
      unless self.profile.name.empty?
        return self.profile.name
      end
    end
    return self.username
  end

  def reset_password_with_email
    reset_password
    UserMailer.reset_password(self).deliver
  end

  def self.find_by_password_reset_code password_reset_code
    User.where(password_reset_code: password_reset_code).first 
  end

  def self.find_by_email email
    User.where(email: email).first
  end

  def push_follower follower
    already = User.all_of({:_id => self.id},
                          {:follower_ids.in => [follower.id]})
                  .first
    return self unless already.nil?
    User.where(:_id => self.id)
        .find_and_modify({:$addToSet => {:follower_ids => follower.id},
                          :$inc => {:followers_count => 1}})
    self.reload
  end

  def push_following following
    already = User.all_of({:_id => self.id},
                          {:following_ids.in => [following.id]})
                  .first
    return self unless already.nil?
    User.where(:_id => self.id)
        .find_and_modify({:$addToSet => {:following_ids => following.id},
                          :$inc => {:following_count => 1}})
    self.reload
  end
end
