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
