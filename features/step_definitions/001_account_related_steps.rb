#Given /^an user exists with an email of "([^"]*)"$/ do |email|
#  FactoryGirl.create(:user, :email => email)
#end

Given /^a logged user with email "([^"]*)"$/ do |email|
  user = Factory(:user, :email => email)
  password = user.password
  And %{"#{user.email}"'s the account is activated}
  And %{the default privacies exist}
  And %{I sign in with "#{email}" and "#{password}"}
end

Given /^recaptcha is disabled$/ do
  PersonalLog::Application.config.recaptcha[:enable] = false  
end

Given /^recaptcha is enabled$/ do
  PersonalLog::Application.config.recaptcha[:enable] = true  
end

Given /^I sign in with "([^"]*)" and "([^"]*)"$/ do |email, password|
  visit signin_path
  fill_in "Email",    :with => email
  fill_in "Password", :with => password
  click_button "Sign in"
end

Then /^I should have (\d+) user(?:|s)$/  do |nr_of_users|
  User.count.should == nr_of_users.to_i
end

Given /^"([^"]*)"'s the account is activated$/ do |email|
  user = User.find_by_email(email)
  user.activate!
end

Then /^"([^"]*)"'s password should be "([^"]*)"$/ do |email, password|
  user = User.find_by_email(email)
  user.has_password?(password).should == true
end

Then /^"([^"]*)"'s display name should be "([^"]*)"$/ do |email, display_name|
  user = User.find_by_email(email)
  user.profile.name.should == display_name
  user.display_name.should == display_name
end

Then /^disable recaptcha for other scenarios/ do
  PersonalLog::Application.config.recaptcha[:enable] = false  
end

Then /^"([^"]*)"'s nickname should be "([^"]*)"$/ do |email, nickname|
  user = User.find_by_email(email)
  user.name.should == nickname
end

Given /^the community account exists$/ do
  # the Community User receives all the ideas abandoned by users when they delete their accounts 
  community_user = User.create!(:name => "community", :email => "community@remindmetolive.com", :password => "thesercretpassword123")
  # we don't let anyone to sign in as the community user
  community_user.block!
end