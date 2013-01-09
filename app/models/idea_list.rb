class IdeaList
  include Mongoid::Document

  field :name,                :type => String
  field :ideas_count,         :type => Integer, default: 0

  belongs_to                  :user
  has_and_belongs_to_many     :ideas, class_name: 'UserIdea'

  validates_presence_of       :name
  validates_length_of         :name, minimum: 3, maximum: 30
  validate                    :user_presence
  validate                    :unique_name_per_user

  def self.owned_by user
    user.idea_lists
  end

  def add_idea_as idea, privacy = nil
    user_idea = nil
    unless user.has_idea? idea
      params = {:idea_id => idea.id, :privacy => privacy}
      user_idea = self.user.create_user_idea! params
    else
      user_idea = self.user.user_idea_for_idea idea
    end
    user_idea = self.ideas.find(user_idea.id) # exception
    return false
  rescue Mongoid::Errors::DocumentNotFound
    self.ideas << user_idea
    self.ideas_count += 1
    self.save
  end

  def add_ideas idea_ids
    idea_ids.each do |idea_id|
      idea = Idea.find idea_id
      add_idea_as idea
    end
  end

  def has_idea idea

  end

  def remove_idea idea
    user_idea = self.ideas.where(:idea_id => idea.id).first
    return false if user_idea.nil?
    self.ideas.delete user_idea
    self.ideas_count -= 1
    return self.save
  end

  private

  def user_presence
    errors.add(:user, "must be present") if user.nil?
  end

  def unique_name_per_user
    errors.add(:name, "must be unique") if
      (not user.nil?) and (not name.nil?) and name_changed? and (not IdeaList.owned_by(user).select { |il| il.name == name && il.id != id }.empty?)
  end
end
