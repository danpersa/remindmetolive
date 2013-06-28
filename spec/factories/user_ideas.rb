FactoryGirl.define do
  factory :simple_user_idea, :class => UserIdea do |user_idea|
    user_idea.privacy              Privacy::Values[:public]
    user_idea.reminder_created_at  Time.now
    user_idea.reminder_date        Time.now.next_year
    user_idea.user                 { FactoryGirl.build(:unique_user) }
    user_idea.idea                 { FactoryGirl.build(:simple_idea) }
  end

  factory :user_idea, :class => UserIdea do |user_idea|
    user_idea.privacy              Privacy::Values[:public]
    user_idea.reminder_created_at  Time.now
    user_idea.reminder_date        Time.now.next_year
    user_idea.user                 { FactoryGirl.build(:unique_user) }
    user_idea.idea                 { FactoryGirl.build(:simple_idea) }
  end

  factory :second_user_idea, :class => UserIdea do |user_idea|
    user_idea.privacy              Privacy::Values[:public]
    user_idea.reminder_created_at  Time.now
    user_idea.reminder_date        Time.now.next_year
    user_idea.user                 { FactoryGirl.build(:unique_user) }
    user_idea.idea                 { FactoryGirl.build(:simple_idea) }
  end
end
