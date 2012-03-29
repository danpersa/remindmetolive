FactoryGirl.define do
  factory :social_event do |social_event|
    social_event.created_by { FactoryGirl.build :unique_user }
  end
end
