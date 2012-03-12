Factory.sequence(:idea_content)    {|n| "ana are mere #{n}" }

FactoryGirl.define do
  factory :idea do |idea|
    idea.content    { Factory.next :idea_content }
    idea.privacy    { Privacy::Values[:public] }
    idea.created_by { Factory.build :unique_user }
    idea.owned_by   { Factory.build :unique_user }
    idea.users_marked_the_idea_good_count 1
    idea.users_marked_the_idea_done_count 1
    idea.users_marked_the_idea_good {
      [Factory.build(:unique_user), Factory.build(:unique_user)]
    }
    idea.users_marked_the_idea_done {
      [Factory.build(:unique_user), Factory.build(:unique_user)]
    }
  end

  factory :simple_idea, :class => Idea do |idea|
    idea.content    { Factory.next :idea_content }
    idea.privacy    { Privacy::Values[:public] }
    idea.created_by { Factory.build :unique_user }
    idea.owned_by   { Factory.build :unique_user }
    idea.users_marked_the_idea_good_count 0
    idea.users_marked_the_idea_done_count 0
  end
end