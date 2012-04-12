class UserIdea
  include Mongoid::Document

  field :privacy,                  :type => Integer
  field :reminder_created_at,      :type => DateTime, :default => Time.now
  field :reminder_date,            :type => Date

  belongs_to :user, inverse_of: :ideas
  belongs_to :idea, inverse_of: :user_ideas

  validates_presence_of       :privacy
  validates_inclusion_of      :privacy, in: [Privacy::Values[:public], Privacy::Values[:private]]
  validate                    :reminder_date_cannot_be_in_the_past

  validates_presence_of       :user

  def set_reminder reminder_date
    self.reminder_created_at = Time.now
    self.reminder_date = reminder_date
  end

  def valid_with_idea?
    self.idea.valid? and self.valid?
  end

  def save_with_idea!
    self.idea.save!
    self.save!
    User.user_creates_idea_notification self.user, idea
  end  

  # sample params
  # {"idea"=>{"content"=>"learn to play"},
  #  "reminder_date"=>"10/10/2012", "privacy"=>"0"}
  def self.new_with_idea params, user
    @user_idea = UserIdea.new(params)
    @user_idea.user = user
    @user_idea.idea.created_by = user
    @user_idea.idea.owned_by = user
    @user_idea.idea.privacy = @user_idea.privacy
    @user_idea
  end

  def self.find_by_id id
    self.first conditions: {_id: id}
  end

  private
  def reminder_date_cannot_be_in_the_past
    errors.add(:reminder_date, "can't be in the past") if
      reminder_date != nil and reminder_date < Date.today
  end
end