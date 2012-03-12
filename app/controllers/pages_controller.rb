class PagesController < ApplicationController
  layout 'one_section_narrow'

  include ApplicationHelper

  def home
    @title = 'Home'
    if signed_in?
      store_current_page
      store_location
      @user_idea = UserIdea.new
      # @remind_me_too_location = HOME_PAGE_LOCATION
      init_feeds_table1
      init_default_sidebar
      render :layout => 'section_with_default_sidebar'
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
