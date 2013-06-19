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

  attr_accessor :content, :privacy, :repeat, :reminder_on

  def initialize(user)
    @user = user
  end

  def submit(params)
    idea_id = params[:idea_id]
    if idea_id.nil?
      idea_attributes = params.slice(:content, :privacy)
                              .merge(created_by: @user, owned_by: @user)
      idea = Idea.new(idea_attributes)
      idea_id = idea.id
    end 

    user_idea_attributes = params.slice(:privacy, :reminder_on, :repeat)
                            .merge(user: @user, idea: idea)


    user_idea = UserIdea.new({:privacy => params[:privacy],
                              :reminder_date => params[:reminder_date],
                              :reminder_created_at => Time.now,
                              :idea => idea_id,
                              :user => self})
    if idea.valid? and user_idea.valid?
      idea.save!
      user_idea.save!
      User.user_creates_idea_notification self, idea
    end
    return user_idea



    user.attributes = params.slice(:username, :email, :password, :password_confirmation)
    profile.attributes = params.slice(:twitter_name, :github_name, :bio)
    self.subscribed = params[:subscribed]
    if valid?
      generate_token
      user.save!
      profile.save!
      true
    else
      false
    end
  end


  def persisted?
    false
  end
  
  def self.model_name
    ActiveModel::Name.new(self, nil, "User")
  end
end
