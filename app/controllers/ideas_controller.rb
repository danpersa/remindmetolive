class IdeasController < ApplicationController
  respond_to :html, :js
  layout 'section_with_default_sidebar'

  before_filter :authenticate
  before_filter :own_idea_or_public, :only => [:show, :users,
                                     :followed_users,
                                     :users_marked_the_idea_good,
                                     :users_marked_the_idea_done]
  before_filter :store_location, :only => [:show, :users, :followed_users,
                                           :users_marked_the_idea_good,
                                           :users_marked_the_idea_done]
  before_filter :store_current_page, :only => [:show, :users, :followed_users,
                                               :users_marked_the_idea_good,
                                               :users_marked_the_idea_done]

  def show
    init_head
    @idea_lists = IdeaList.owned_by current_user
    respond_to do |format|
      format.html {
        init_default_sidebar
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
      }
      format.js {
        render :partial => 'ideas/update_followed_users_table'
      }
    end
  end

  def users_marked_the_idea_good
    init_head
    @users_marked_the_idea_good = 
      @idea.users_marked_the_idea_good
           .page(params[:page])
           .per(RemindMeToLive::Application.config.items_per_page)
    respond_to do |format|
      format.html {
        init_default_sidebar
      }
      format.js {
        render :partial => 'ideas/update_users_marked_the_idea_good_table'
      }
    end
  end

  def users_marked_the_idea_done
    init_head
    @users_marked_the_idea_done = 
      @idea.users_marked_the_idea_done
           .page(params[:page])
           .per(RemindMeToLive::Application.config.items_per_page)
    respond_to do |format|
      format.html {
        init_default_sidebar
      }
      format.js {
        render :partial => 'ideas/update_users_marked_the_idea_done_table'
      }
    end
  end

  def update
    @idea = Idea.find(params[:id])
    idea_list_ids = params[:idea][:idea_list_tokens]
    @idea.put_in_idea_lists_of_user idea_list_ids, current_user
    
    flash[:success] = "Successfully updated idea!"
    redirect_to @idea
  end

  private

  def init_head
    @user = current_user
    @user_idea = @user.user_idea_for_idea @idea
  end
end
