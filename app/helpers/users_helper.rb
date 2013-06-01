module UsersHelper
  include ApplicationHelper

  def gravatar_for(user, options = { :size => 150 })
    gravatar_image_tag(user.email.downcase, :alt => user.display_name,
                                            :class => 'gravatar',
                                            :gravatar => options)
  end

  def link_to_user user
    "#{link_to user.display_name, user}"
  end

  def display_first_users event
    html = ""
    if event.users_count == 1
      html << "<strong>#{link_to_user event.users[0]}</strong>"
    elsif event.users_count == 2
      html << "<strong>#{link_to_user event.users[0]}</strong> and <strong>#{link_to_user event.users[1]}</strong> "
    else
      other_user_count = event.users_count - 2

      link_to_other_people = link_to '#' do
        "<strong>#{other_user_count} other #{pluralize_without_numbers(other_user_count, 'person', 'people')}</strong>".html_safe
      end

      html << "<strong>#{link_to_user event.users[0]}</strong>, <strong>#{link_to_user event.users[1]}</strong> and "
      html << link_to_other_people
    end
    return html.html_safe
  end

  def users_ideas_active_class
    return 'active' if "#{params[:controller].parameterize}_#{params[:action].parameterize}" == 'user_ideas_index'
  end

  def users_edit_class
    return 'active' if "#{params[:controller].parameterize}_#{params[:action].parameterize}" == 'users_edit'
  end

  def init_social_events_for_user
    if current_user.id == @user.id
      @social_events = CreateIdeaSocialEvent.of_user(@user)
                          .page(params[:page])
                          .per(RemindMeToLive::Application.config.items_per_page)
    else
      @social_events = CreateIdeaSocialEvent.public_of_user(@user)
                          .page(params[:page])
                          .per(RemindMeToLive::Application.config.items_per_page)
    end
  end
end
