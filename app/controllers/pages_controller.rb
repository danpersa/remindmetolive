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
  end

  def reset_password_mail_sent
    @title = 'Reset Password Mail Sent'
  end
end
