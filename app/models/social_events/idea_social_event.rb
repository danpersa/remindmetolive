class IdeaSocialEvent < SocialEvent
  include Mongoid::Document

  belongs_to :idea
end
