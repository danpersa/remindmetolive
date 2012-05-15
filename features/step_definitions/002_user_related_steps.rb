Given /^"([^"]*)"' shares an idea with a reminder$/ do |email|
  user = User.find_by_email(email)
  user.create_new_idea! :content => 'play the violin',
                          :privacy => Privacy::Values[:public],
                          :reminder_date => Time.now.next_year
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