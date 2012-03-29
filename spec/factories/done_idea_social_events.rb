FactoryGirl.define do
  factory :done_idea_social_event do |done_idea_social_event|
    done_idea_social_event.created_by { FactoryGirl.build :unique_user }
    done_idea_social_event.idea       { FactoryGirl.build :simple_idea }
  end
end
