FactoryGirl.define do
  factory :good_idea_social_event do |good_idea_social_event|
    good_idea_social_event.created_by { FactoryGirl.build :unique_user }
    good_idea_social_event.idea       { FactoryGirl.build :simple_idea }
  end
end
