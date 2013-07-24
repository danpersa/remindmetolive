class UserIdea
  include Mongoid::Document

  field :privacy,                  :type => Integer
  field :reminder_created_at,      :type => DateTime, :default => Time.now
  field :reminder_date,            :type => Date
  field :repeat,                   :type => Integer
  field :reminder_on,              :type => String

  belongs_to :user, inverse_of: :ideas
  belongs_to :idea, inverse_of: :user_ideas

  has_and_belongs_to_many    :idea_lists, inverse_of: :ideas

  validates_presence_of       :privacy
  validates_inclusion_of      :privacy, in: [Privacy::Values[:public], Privacy::Values[:private]]

  validates_presence_of       :user
  validates_presence_of       :idea
  validate                    :reminder_date_cannot_be_in_the_past
  validate                    :one_user_idea_per_idea_per_user

  def set_reminder reminder_date
    self.reminder_created_at = Time.now
    self.reminder_date = reminder_date
  end

  def self.find_by_id id
    UserIdea.where(_id: id).first
  end

  private
  def reminder_date_cannot_be_in_the_past
    errors.add(:reminder_date, "can't be in the past") if
      reminder_date != nil and reminder_date < Date.today
  end

  def one_user_idea_per_idea_per_user
    errors.add(:idea, "can't create two user ideas for the same idea") if
      not self.idea.nil? and UserIdea.not_in(_id: [self.id])
              .where(idea_id: self.idea.id, user_id: self.user.id).count > 0
  end

  def self.delete_all_for user
    UserIdea.delete_all user_id: user.id
  end

  def self.delete_all_for_idea idea
    UserIdea.delete_all idea_id: idea.id
  end
end