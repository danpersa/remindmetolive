FactoryGirl.define do
  factory :good_idea_social_event do |good_idea_social_event|
    good_idea_social_event.created_by { Factory.build :unique_user }
    good_idea_social_event.idea       { Factory.build :simple_idea }
  end
end
