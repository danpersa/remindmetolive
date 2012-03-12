Factory.sequence(:idea_list_name)    {|n| "idea_list_name#{n}" }

FactoryGirl.define do
  factory :idea_list do |idea_list|
    idea_list.name { Factory.next :idea_list_name }
    idea_list.ideas { [Factory.build(:idea)] }
    idea_list.user { Factory :unique_user }
  end
end
