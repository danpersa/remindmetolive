FactoryGirl.define do
  factory :following_user_social_event do |following_user_social_event|
    following_user_social_event.created_by { FactoryGirl.build :unique_user }
    following_user_social_event.users       { [ FactoryGirl.build(:unique_user) ] }
  end
end
