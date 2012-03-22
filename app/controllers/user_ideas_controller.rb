class UserIdeasController < ApplicationController
  before_filter :authenticate

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

  def index
    @user = current_user
    @user_ideas = current_user.ideas_ordered_by_reminder_created_at.page(params[:page]).per(10)
    # we store the location so we can be redirected here after idea delete
    store_location
    store_current_page
    init_default_sidebar
    render :layout => 'section_with_default_sidebar'
  end
end
