Given /^"([^"]*)" has (\d+) idea lists?$/ do |email, number_of_idea_lists|
  user = User.find_by_email(email)
  number_of_idea_lists.to_i.times do
    Factory(:idea_list, :user => user)
  end
end

When /^I click on delete icon$/ do
  idea_link = page.find(:css, '.ui-icon-close') 
  idea_link.click
end

When /^I fill in "([^"]*)" with the idea list name$/ do |field|
  idea_list_name = IdeaList.first.id
  And %{fill in "#{field}" with "#{idea_list_name}"}
end


Then /^I should see all of "([^"]*)" idea lists?$/ do |email|
  user = User.find_by_email(email)
  user.idea_lists.each do |idea_list|
    page.should have_content(idea_list.name)
  end
end

Then /^I should not see all of "([^"]*)" idea lists?$/ do |email|
  user = User.find_by_email(email)
  user.idea_lists.each do |idea_list|
    page.should_not have_content(idea_list.name)
  end
end


