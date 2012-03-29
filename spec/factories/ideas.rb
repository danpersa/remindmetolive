FactoryGirl.define do
  sequence :idea_content do |n|
    "ana are mere #{n}"
  end

  factory :idea do |idea|
    idea.content    { FactoryGirl.generate :idea_content }
    idea.privacy    { Privacy::Values[:public] }
    idea.created_by { FactoryGirl.build :unique_user }
    idea.owned_by   { FactoryGirl.build :unique_user }
    idea.users_marked_the_idea_good_count 1
    idea.users_marked_the_idea_done_count 1
    idea.users_marked_the_idea_good {
      [FactoryGirl.build(:unique_user), FactoryGirl.build(:unique_user)]
    }
    idea.users_marked_the_idea_done {
      [FactoryGirl.build(:unique_user), FactoryGirl.build(:unique_user)]
    }
  end

  factory :simple_idea, :class => Idea do |idea|
    idea.content    { FactoryGirl.generate :idea_content }
    idea.privacy    { Privacy::Values[:public] }
    idea.created_by { FactoryGirl.build :unique_user }
    idea.owned_by   { FactoryGirl.build :unique_user }
    idea.users_marked_the_idea_good_count 0
    idea.users_marked_the_idea_done_count 0
  end
end