FactoryGirl.define do
  sequence :idea_list_name do |n|
    "idea_list_name#{n}"
  end

  factory :idea_list do |idea_list|
    idea_list.name { FactoryGirl.generate :idea_list_name }
    idea_list.ideas { [FactoryGirl.build(:idea)] }
    idea_list.user { FactoryGirl.create :unique_user }
  end
end
