Given /^"([^"]*)"' shares an idea with a reminder$/ do |email|
  user = User.find_by_email(email)
  idea = FactoryGirl.create(:idea, :created_by => user, :owned_by => user)
  user_idea = FactoryGirl.create(:user_idea, :idea => idea, :user => user)
  FactoryGirl.create(:create_idea_social_event,
                     :created_by => user,
                     :idea => idea)
end

Given /^"([^"]*)" follows "([^"]*)"$/ do |email, followed_email|
  user = User.find_by_email(email)
  followed_user = User.find_by_email(followed_email)
  user.follow!(followed_user)
end

Then /^I should see "([^"]*)"'s display name$/ do |email|
  user = User.find_by_email(email)
  page.should have_content(user.display_name)
end

Then /^"([^"]*)" should follow "([^"]*)"$/ do |email, followed_email|
  user = User.find_by_email(email)
  followed_user = User.find_by_email(followed_email)
  user.following(followed_user).should_not be_nil
end