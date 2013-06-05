require 'mandrill'

class PagesController < ApplicationController
  include ApplicationHelper

  layout 'one_section_narrow'
  respond_to :html, :js

  def home
    @title = 'Home'
    if signed_in?
      init_feeds_table
      respond_to do |format|
        format.html {
          store_current_page
          store_location
          @user_idea = UserIdea.new
          init_default_sidebar
          render :layout => 'section_with_default_sidebar'
        }
        format.js {
          render :partial => 'social_events/table_update'
        }
      end
    end
  end

  def contact
    @title = 'Contact'
  end

  def about
    @title = 'About'
  end

  def help
    @title = 'Help'

    m = Mandrill::API.new # All official Mandrill API clients will automatically pull your API key from the environment
    rendered = m.templates.render 'daily-reminders', [
      {:name => 'display_name', :content => 'Danix'},
      {:name => 'reminders', :content => '<li>Remind me to live</li><li>Remind me to  play the piano</li>'}]
    @mail_template = rendered['html'] # print out the rendered HTML

    m.messages.send_template 'daily-reminders', [
      {:name => 'display_name', :content => 'Danix'},
      {:name => 'reminders', :content => '<li>Remind me to live</li><li>Remind me to  play the piano</li>'}],
      {
        html: "<p>Example HTML content</p>",
        text: "Example text content",
        subject: "You want to be reminded of something",
        from_email: "reminders@remindmetolive.com",
        from_name: "Remind Me To Live",
        to: [
            {
                email: "dan.persa@gmail.com",
                name: "Dan Persa"
            }
        ]
    }
  end

  def reset_password_mail_sent
    @title = 'Reset Password Mail Sent'
  end
end
