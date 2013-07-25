class IdeaForm
  include Virtus
  # Rails 4: include ActiveModel::Model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations


  validates_presence_of       :privacy
  validates_inclusion_of      :privacy, in: [Privacy::Values[:public], Privacy::Values[:private]]


  validates_presence_of       :repeat
  validates_inclusion_of      :repeat, in: [  
                                              Repeat::Values[:never],
                                              Repeat::Values[:every_day],
                                              Repeat::Values[:every_week],
                                              Repeat::Values[:every_month],
                                              Repeat::Values[:every_season],
                                              Repeat::Values[:every_year]
                                           ] 

  validate                    :reminder_on_cannot_be_in_the_past
  validate                    :content_and_idea_id

  attribute :content, String
  attribute :privacy, Integer
  attribute :repeat, Integer
  attribute :reminder_on, String
  attribute :idea_id, Integer

  def initialize(user)
    @user = user
  end

  def submit(params)

    self.privacy = params[:privacy]
    self.content = params[:content]
    self.repeat = params[:repeat]
    self.reminder_on = params[:reminder_on]
    self.idea_id = params[:idea_id]

    next_reminder = NextReminder.from DateTime.now.utc.midnight,
                                  params[:repeat],
                                  params[:reminder_on]

    @reminder_date = next_reminder.date
    unless valid?
      puts 'NOT VALID'
      self.errors.each do |error|
        puts error
        puts errors[error]
      end
      return false
    end

    idea = initialize_idea params

    user_idea = initalize_user_idea params, idea, next_reminder.date
    if idea.new_record?
      User.user_creates_idea_notification @user, idea  
    end
    idea.save!
    if user_idea.new_record?
      # user shares idea notification
    end
    user_idea.save!  
    true
  end


  def persisted?
    false
  end
  
  def self.model_name
    ActiveModel::Name.new(self, nil, "IdeaForm")
  end

  private

  def initialize_idea params
    unless idea_id_present?
      idea_attributes = params.slice(:content, :privacy)
                              .merge(created_by: @user, owned_by: @user)
      idea = Idea.new idea_attributes
      self.idea_id = idea.id
    else
      idea = Idea.find_by_id self.idea_id
    end
    idea
  end

  def initalize_user_idea params, idea, next_reminder_date

    user_idea_attributes = params.slice(:privacy, :reminder_on, :repeat)
                                 .merge user: @user,
                                        reminder_date: next_reminder_date,
                                        idea_id: self.idea_id,
                                        :reminder_created_at => Time.now
    if @user.has_idea? idea
      user_idea = @user.user_idea idea
      user_idea.write_attributes user_idea_attributes
    else
      user_idea = UserIdea.new user_idea_attributes
    end
    user_idea
  end

private
  def content_and_idea_id
    unless idea_id_present?
      validates_presence_of       :content
      validates_length_of         :content, minimum: 3, maximum: 255
    end
  end

  def idea_id_present?
    return not(self.idea_id.nil?)
  end

  def content_present?
    return not(self.content.nil?)
  end

  def reminder_on_cannot_be_in_the_past
    errors.add(:reminder_on, "can't be in the past") if
      @reminder_date != nil and @reminder_date < Date.today
  end
end
