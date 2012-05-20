FactoryGirl.define do
  factory :share_idea_social_event do |share_idea_social_event|
    share_idea_social_event.created_by { FactoryGirl.build :unique_user }
    share_idea_social_event.users      { [ FactoryGirl.build(:unique_user) ] }
    share_idea_social_event.idea       { FactoryGirl.build :simple_idea }
  end
end
