FactoryGirl.define do
  factory :followed_user_social_event do |followed_user_social_event|
    followed_user_social_event.created_by { Factory.build :unique_user }
    followed_user_social_event.user       { Factory.build :unique_user }
  end
end
