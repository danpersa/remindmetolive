FactoryGirl.define do
  factory :create_idea_social_event do |create_idea_social_event|
    create_idea_social_event.created_by { FactoryGirl.build :unique_user }
    create_idea_social_event.idea       { FactoryGirl.build :simple_idea }
  end
end
