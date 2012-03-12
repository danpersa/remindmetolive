class UserSocialEvent < SocialEvent
  include Mongoid::Document

  belongs_to :user
end
