FactoryGirl.define do
  factory :done_idea_social_event do |done_idea_social_event|
    done_idea_social_event.created_by { Factory.build :unique_user }
    done_idea_social_event.idea       { Factory.build :simple_idea }
  end
end
