class IdeasController < ApplicationController
  respond_to :html, :js

  before_filter :authenticate
  before_filter :own_idea_or_public, :only => [:show, :users, :followed_users]
  before_filter :store_location, :only => [:show, :users, :followed_users]
  before_filter :store_current_page, :only => [:show, :users, :followed_users]

  def show
    init_head
    respond_to do |format|
      format.html {
        init_default_sidebar
        render :layout => 'section_with_default_sidebar'
      }
      format.js {
        render :partial => 'ideas/update_idea_head'
      }
    end
  end

  def users
    init_head
    @public_user_ideas = 
      @idea.public_user_ideas
           .page(params[:page])
           .per(RemindMeToLive::Application.config.items_per_page)

    respond_to do |format|
      format.html {
        init_default_sidebar
        render :layout => 'section_with_default_sidebar'
      }
      format.js {
        render :partial => 'ideas/update_users_table'
      }
    end
  end

  def followed_users
    init_head
    @public_user_ideas_of_users_followed_by_current_user = 
      @idea.public_user_ideas_of_users_followed_by(current_user)
           .page(params[:page])
           .per(RemindMeToLive::Application.config.items_per_page)

    respond_to do |format|
      format.html {
        init_default_sidebar
        render :layout => 'section_with_default_sidebar'
      }
      format.js {
        render :partial => 'ideas/update_followed_users_table'
      }
    end
  end

  private

  def init_head
    @user = current_user
    @user_idea = @user.user_idea_for_idea @idea
  end
end
