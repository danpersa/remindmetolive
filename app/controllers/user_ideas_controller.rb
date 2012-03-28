class UserIdeasController < ApplicationController
  before_filter :authenticate
  before_filter :shared_by_logged_user, :only => [:destroy]

  def index
    @user = current_user
    @user_ideas = current_user.ideas_ordered_by_reminder_created_at.page(params[:page]).per(10)
    # we store the location so we can be redirected here after idea delete
    store_location
    store_current_page
    init_default_sidebar
    render :layout => 'section_with_default_sidebar'
  end

  def create
    @user_idea = UserIdea.new_with_idea params[:user_idea], current_user
    @idea = @user_idea.idea
    if @user_idea.valid_with_idea?
      @user_idea.save_with_idea!
      flash[:success] = "Idea created!"
      redirect_to root_path
      return
    end

    init_feeds_table1
    @user = current_user
    init_default_sidebar
    render 'pages/home', :layout => 'section_with_default_sidebar'
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
