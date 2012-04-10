class UserIdeasController < ApplicationController
  include UsersHelper

  layout 'section_with_default_sidebar'

  before_filter :authenticate
  before_filter :shared_by_logged_user, :only => [:destroy]
  before_filter :own_idea_or_public, :only => [:new_for_existing_idea]

  respond_to :html, :js

  def index
    @user = current_user
    @user_ideas = current_user.ideas_ordered_by_reminder_created_at.page(params[:page]).per(10)
    # we store the location so we can be redirected here after idea delete
    store_location
    store_current_page
    init_default_sidebar
  end

  def new_for_existing_idea
    @user_idea = UserIdea.new
    @dialog_content = 'user_ideas/form_with_idea'
    #if @idea.shared_by? current_user
      #logger.info  "idea is shared"
      #@title = "Create new reminder"
    #else
      logger.info  "idea is not shared"
      @title = "Remind me too"
    #end  
    @submit_button_name = "Create reminder"
    respond_with_remote_form 'user_ideas/new_for_existing_idea'
  end


  def new_for_existing_idea_from_location
    location = params[:location]
    init_reminders_form_url(location)
    new_for_existing_idea
  end

  def create
    @user_idea = UserIdea.new_with_idea params[:user_idea], current_user
    @idea = @user_idea.idea
    unless @idea.id.nil?
      @idea = Idea.find(@idea.id) 
      @user_idea.idea = @idea
    end
    @user = @idea.owned_by

    respond_to do |format|
      if @user_idea.valid_with_idea?
        @user_idea.save_with_idea!
        flash[:success] = "Idea created!"
        format.html {
          redirect_back_or root_path
        }
        format.js {
          init_social_events_for_user
          @update_table_partial = 'social_events/table_update'
          respond_with_remote_form
          respond_with(@user_idea, :layout => !request.xhr?)
        }
      else
        format.html {
          init_feeds_table1
          @user = current_user
          init_default_sidebar
          render 'pages/home'
        }
        format.js {
          respond_with_remote_form
          respond_with(@user_idea, :layout => !request.xhr?)
        }
      end
    end
  end

  def update
    @idea = Idea.find(params[:id])
    @idea.idea_list_tokens = params[:idea][:idea_list_tokens]
    if @idea.save!
      flash[:success] = "Successfully updated idea!"
      redirect_to @idea
    else
      render :action => 'show'
    end
  end

  def destroy
    @user = current_user
    idea = @user_idea.idea
    @user_idea.destroy
    if idea.private?
      idea.destroy
    end
    respond_to do |format|
      flash[:success] = 'Successfully deleted shared idea!'
      format.html { redirect_back_or root_path }
    end
  end

  private

  def shared_by_logged_user
    @user_idea = UserIdea.find(params[:id])
    redirect_to root_path if @user_idea.nil? or current_user.id != @user_idea.user.id
  rescue Mongoid::Errors::DocumentNotFound
    redirect_to root_path
  end
end
