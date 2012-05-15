Given /^I am a guest$/ do
  
end

Given /^"([^"]*)" has and idea list of name "([^"]*)"$/ do |email, idea_list_name|
  step %{I am on the new idea list page}
  step %{I fill in "Name" with "#{idea_list_name}"}
  step %{I press "Create List Of Ideas"}  
end

Given /^"([^"]*)" has a display name of "([^"]*)"$/ do |email, display_name|
  step %{I am on the edit public profile page of "brandon@example.com"}
  step %{I fill in "Name" with "#{display_name}"}
  step %{I press "Update Public Profile"}
end
