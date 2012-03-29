FactoryGirl.define do
  factory :followed_user_social_event do |followed_user_social_event|
    followed_user_social_event.created_by { FactoryGirl.build :unique_user }
    followed_user_social_event.user       { FactoryGirl.build :unique_user }
  end
end
