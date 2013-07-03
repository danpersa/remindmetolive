class UserIdeasController < ApplicationController
  include UsersHelper

  layout 'section_with_default_sidebar'

  before_filter :authenticate
  before_filter :shared_by_logged_user, :only => [:destroy]

  respond_to :html, :js

  def index
    @user = current_user
    @user_ideas = current_user.ideas_ordered_by_reminder_created_at
                              .page(params[:page])
                              .per(RemindMeToLive::Application.config.items_per_page)
    # we store the location so we can be redirected here after idea delete
    store_location
    store_current_page
    init_default_sidebar
  end



  def create
    @user_idea = UserIdea.new_with_idea params[:user_idea], current_user
    @idea = @user_idea.idea
    @user = @idea.owned_by

    respond_to do |format|
      if @user_idea.valid_with_idea?
        @user_idea.save_with_idea!
        flash[:success] = "Idea created!"
        format.html {
          redirect_back_or root_path
        }
      else
        format.html {
          logger.info '--- reminder date ----'
          logger.info @user_idea.reminder_date
          logger.info '--- user idea errors ---'
          @user_idea.errors.each do |error|
            logger.info error
            logger.info @user_idea.errors[error]
          end
          logger.info '--- idea errors ---'
          @user_idea.idea.errors.each do |error|
            logger.info error
            logger.info @user_idea.idea.errors[error]
          end
          init_feeds_table
          @user = current_user
          init_default_sidebar
          render 'pages/home'
        }
      end
      format.js {
          respond_with_remote_form
          respond_with(@user_idea, :layout => !request.xhr?)
        }
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
