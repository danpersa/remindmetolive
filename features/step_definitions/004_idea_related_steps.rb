Given /^"([^"]*)" shares (\d+) ideas? on "([^"]*)"$/ do |email, number_of_ideas, date|
  user = User.find_by_email(email)
  ideas = []
  number_of_ideas.to_i.times do
    idea = FactoryGirl.create(:idea, :created_by => user, :owned_by => user)
    ideas << idea
    user_idea = FactoryGirl.create :user_idea, :idea => idea,
                                   :user => user,
                                   :reminder_date => Time.parse(date)
    FactoryGirl.create :create_idea_social_event,
                       :created_by => user,
                       :idea => idea
  end
end

Given /^"([^"]*)" shares (\d+) ideas?$/ do |email, number_of_ideas|
  user = User.find_by_email(email)
  ideas = []
  number_of_ideas.to_i.times do
    user.create_new_idea! :content => 'play the piano',
                          :privacy => Privacy::Values[:public],
                          :reminder_date => Time.now.next_year
  end
end

Given /^"([^"]*)" shares the same idea$/ do |email|
  user = User.find_by_email(email)
  idea = Idea.first
  user.create_user_idea! :idea_id => idea.id,
                         :reminder_date => Time.now.next_year,
                         :privacy => Privacy::Values[:public]
end

Then /^I should see "([^"]*)"'s ideas content$/ do |email|
  user = User.find_by_email(email)
  user.ideas.each do |idea|
    page.should have_content(idea.content)
  end
end

Then /^I should see "([^"]*)"'s ideas content trimmed$/ do |email|
  user = User.find_by_email(email)
  user.ideas.each do |idea|
    page.should have_content(idea.content.truncate(22))
  end
end
