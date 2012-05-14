Given /^I am a guest$/ do
  
end

Given /^"([^"]*)" has and idea list of name "([^"]*)"$/ do |email, idea_list_name|
  And %{I am on the new idea list page}
  And %{I fill in "Name" with "#{idea_list_name}"}
  And %{I press "Create idea list"}  
end

Given /^"([^"]*)" has a display name of "([^"]*)"$/ do |email, display_name|
  And %{I am on the edit public profile page of "brandon@example.com"}
  And %{I fill in "Name" with "#{display_name}"}
  And %{I press "Update public profile"}
end
