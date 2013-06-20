class IdeaForm
  # Rails 4: include ActiveModel::Model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  validates_presence_of       :privacy
  validates_inclusion_of      :privacy, in: [Privacy::Values[:public], Privacy::Values[:private]]

  validates_presence_of       :content
  validates_length_of         :content, minimum: 3, maximum: 255

  validates_inclusion_of      :repeat, in: [
                                              Repeat::Values[:every_day],
                                              Repeat::Values[:every_week],
                                              Repeat::Values[:every_month],
                                              Repeat::Values[:every_season],
                                              Repeat::Values[:every_year]
                                           ] 

  validate                    :reminder_on_cannot_be_in_the_past

  attr_accessor :content, :privacy, :repeat, :reminder_on, :idea_id

  def initialize(user)
    @user = user
  end

  def submit(params)
    self.privacy = params[:privacy]
    self.content = params[:content]
    self.repeat = params[:repeat]
    self.reminder_on = params[:reminder_on]
    self.idea_id = params[:idea_id]

    unless valid?
      return false
    end

    idea = initialize_idea params

    next_reminder = NextReminder.new DateTime.now.utc,
                                     params[:repeat],
                                     params[:reminder_on]

    user_idea = initalize_user_idea params, idea, next_reminder.date

    idea.save!
    
    
    if next_reminder.date.nil?
      unless user_idea.new_record?
        # if next reminder is null and we have a user_idea, we delete it
        user_idea.destroy!
      end
      # if next reminder is null, we don't create a new user idea
    else
      if user_idea.new_record?
        user_idea.save!
      else
        user_idea.update_attributes! user_idea_attributes
      end      
    end
    User.user_creates_idea_notification @user, idea
    true
  end


  def persisted?
    false
  end
  
  def self.model_name
    ActiveModel::Name.new(self, nil, "User")
  end

  private

  def initialize_idea params
    if self.idea_id.nil?
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

    user_idea = nil                                    
    if @user.has_idea? idea
      user_idea = @user.user_idea idea
    else
      user_idea = UserIdea.new user_idea_attributes
    end
    user_idea
  end
end
