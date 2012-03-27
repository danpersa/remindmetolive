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
  	puts params[:user_idea]
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
    # if the idea was not shared with other users, we destroy it
    unless @idea.shared_with_other_users?
      @idea.destroy
    else
      Idea.transaction do
        IdeaListOwnership.destroy_for_idea_of_user(@idea, @user)
        Reminder.destroy_for_idea_of_user(@idea, @user)
        @idea.donate_to_community!
      end
    end
    respond_to do |format|
       format.html { redirect_back_or root_path }
       format.js {
         # we parse the current page path and extract the user on which profile page we are on
         path_hash = url_to_hash(current_page)
         user_id = path_hash[:id]
         page = path_hash[:page]
         @table_params = { :controller => "users",
                           :action => "ideas",
                           :id => user_id,
                           :page => page }
         @ideas = Idea.owned_by(@user).includes(:user).page(page).per(@@items_per_page)
       }
     end
  end

  private

  def shared_by_logged_user
    @user_idea = UserIdea.find(params[:id])
    redirect_to root_path unless not @user_idea.nil? and current_user?(@user_idea.user)
  rescue Mongoid::Errors::DocumentNotFound
    redirect_to root_path
  end
end
