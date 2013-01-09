require 'notifications'

class Idea
  include Mongoid::Document
  include Mongoid::Timestamps
  extend RemindMeToLive::Notifications

  attr_accessor :users_marked_the_idea_good
  attr_accessor :users_marked_the_idea_done
  attr_reader :idea_list_tokens

  field :content                         ,  type: String
  field :privacy                         ,  type: Integer
  field :users_marked_the_idea_good_count,  type: Integer, default: 0
  field :users_marked_the_idea_done_count,  type: Integer, default: 0

  belongs_to :created_by, :class_name => 'User'
  belongs_to :owned_by,   :class_name => 'User'

  has_and_belongs_to_many     :users_marked_the_idea_good, :class_name => 'User', :inverse_of => nil
  has_and_belongs_to_many     :users_marked_the_idea_done, :class_name => 'User', :inverse_of => nil
  has_many                    :user_ideas

  validates_presence_of       :privacy
  validates_inclusion_of      :privacy, in: [Privacy::Values[:public], Privacy::Values[:private]]

  validates_presence_of       :content
  validates_length_of         :content, minimum: 3, maximum: 255

  def mark_as_good_by! user
    return if self.marked_as_good_by? user
    self.add_to_set :users_marked_the_idea_good_ids, user.id
    self.users_marked_the_idea_good_count += 1
    self.save!
    self.reload
    User.user_marks_idea_as_good_notification user, self
  end

  def unmark_as_good_by! user
    return unless self.marked_as_good_by? user
    self.users_marked_the_idea_good.delete user
    self.users_marked_the_idea_good_count -= 1
    self.save!
    self.reload
    User.user_unmarks_idea_as_good_notification user, self
  end

  def marked_as_good_by? user
    self.users_marked_the_idea_good.include? user
  end

  def mark_as_done_by! user
    return if self.marked_as_done_by? user
    self.add_to_set :users_marked_the_idea_done_ids, user.id
    self.users_marked_the_idea_done_count += 1
    self.save!
    self.reload
    User.user_marks_idea_as_done_notification user, self
  end

  def unmark_as_done_by! user
    return unless self.marked_as_done_by? user
    self.users_marked_the_idea_done.delete user
    self.users_marked_the_idea_done_count -= 1
    self.save!
    self.reload
    User.user_unmarks_idea_as_done_notification user, self
  end

  def marked_as_done_by? user
    self.users_marked_the_idea_done.include? user
  end

  def public?
    return true if self.privacy == Privacy::Values[:public]
    false
  end

  def private?
    return true if self.privacy == Privacy::Values[:private]
    false
  end

  def public_user_ideas
    self.user_ideas.where(:privacy => Privacy::Values[:public])
  end

  def public_user_ideas_of_users_followed_by user
    self.user_ideas.where(:user_id.in => user.following_ids, :privacy => Privacy::Values[:public])
  end

  def shared_by_many_users?
    return false unless self.user_ideas.count > 1
    true
  end

  def self.find_by_id id
    Idea.where(_id: id).first
  end

  def exists?
    idea = Idea.find_by_id self.id
    return true unless idea.nil?
    return false
  end

  def idea_lists_of user
    user_idea = user.user_idea_for_idea self
    return [] if user_idea.nil?
    idea_lists = user.idea_lists.in(:idea_ids => [user_idea.id])
    return idea_lists
  end

  def idea_list_ids_as_json_of user
    idea_lists_of(user).map{|idea_list| idea_list.id}.to_json
  end

  def put_in_idea_lists_of_user idea_list_ids, user
    idea_lists_containing_idea = self.idea_lists_of user
    # puts 'initial lists: '
    # puts idea_lists_containing_idea.map{|idea_list| idea_list.id}
    idea_lists_containing_idea_ids = idea_lists_containing_idea.map{|idea_list| idea_list.id.to_s}
    idea_lists_ids_to_be_removed_from = idea_lists_containing_idea_ids - idea_list_ids

    # puts 'we remove: '
    # puts idea_lists_ids_to_be_removed_from

    idea_lists_ids_to_be_removed_from.each do |idea_list_id|
      idea_list = IdeaList.where(_id: idea_list_id).first
      idea_list.remove_idea self
    end

    # debug
    # idea = Idea.find self.id
    # idea_lists = idea.idea_lists_of user
    # puts 'after remove'
    # puts idea_lists.map{|idea_list| idea_list.id}
    # debug

    idea_list_ids.each do |idea_list_id|
      idea_list = IdeaList.where(_id: idea_list_id).first
      # puts "we add to: "
      # puts idea_list.id
      idea_list.add_idea_as self unless idea_list.nil?
    end
    # puts ""
  end
end
