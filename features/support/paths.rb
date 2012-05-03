module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /^the home\s?page$/
      '/'

    when /^the sign up\s?page$/
      '/signup'
      
    when /^the sign in\s?page$/
      '/signin'
      
    when /^the change password\s?page$/
      '/change-password'
      
    when /^the "(.+)"'s activation page$/
      user = User.find_by_email($1)
      activate_path + '?activation_code=' + user.activation_code
    
    when /^the edit profile page of "(.+)"$/
      user = User.find_by_email($1)
      edit_user_path(user)
    
    when /^the edit public profile page of "(.+)"$/
      user = User.find_by_email($1)
      user_path(user) + "/profile"
      
    when /^the profile page of "(.+)"$/
      user = User.find_by_email($1)
      user_path(user)
      
    when /^the followers page of "(.+)"$/
      user = User.find_by_email($1)
      user_path(user) + "/followers"
      
    when /^the following page of "(.+)"$/
      user = User.find_by_email($1)
      user_path(user) + "/following"
    
    when /^the shared idea page$/
      idea = Idea.first
      idea_path(idea) + "/users"
    
    when /^the "brandon@example.com"'s idea page$/
      idea = Idea.first
      idea_path(idea)
    
    when /^the new idea list page$/
      new_idea_list_path
      
    when /^the calendar page$/
      reminders_path
      
    when /^the calendar page on "(.+)"$/
      reminders_path + "?month=" + $1
    
    when /^the "(.+)"'s ideas page$/
      user = User.find_by_email($1)
      user_path(user) + "/ideas"
      
      
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)

