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

  def valid_with_idea?
    self.idea.valid? and self.valid?
  end

  def save_with_idea!
    if self.idea.exists?
      if self.save! and self.privacy == Privacy::Values[:public]
        User.user_shares_idea_notification self.user, self.idea
      end
    else
      if self.idea.save! and self.save!
        User.user_creates_idea_notification self.user, self.idea
      end
    end
  end

  # sample params
  # {"idea"=>{"content"=>"learn to play"},
  #  "reminder_date"=>"10/10/2012", "privacy"=>"0"}
  def self.new_with_idea params, user
    @user_idea = UserIdea.new(params)
    @user_idea.user = user
    if @user_idea.idea.exists?
      @user_idea.idea.reload
    else
      @user_idea.idea.created_by = user
      @user_idea.idea.owned_by = user
      @user_idea.idea.privacy = @user_idea.privacy
    end
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

  def one_user_idea_per_idea_per_user
    errors.add(:idea, "can't create two user ideas for the same idea") if
      not self.idea.nil? and UserIdea.not_in(_id: [self.id])
              .where(idea_id: self.idea.id, user_id: self.user.id).count > 0
  end
end