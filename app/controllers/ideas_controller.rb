class IdeasController < ApplicationController
  before_filter :authenticate, :only => [:show, :users, :followed_users]
  #before_filter :own_idea, :only => :destroy
  before_filter :own_idea_or_public, :only => [:show, :users, :followed_users]
  before_filter :store_location, :only => [:show, :users, :followed_users]
  before_filter :store_current_page, :only => [:show, :users, :followed_users]

  @@items_per_page = 10

  # def create
  #   logger.info params
  #   @user_idea = current_user.create_new_idea!(params[:idea])
  #   @idea = @user_idea.idea
  #   if @idea.valid? and @user_idea.valid?
  #     flash[:success] = "Idea created!"
  #     redirect_to root_path
  #     return
  #   end

  #   init_feeds_table1
  #   @user = current_user
  #   init_default_sidebar
  #   render 'pages/home', :layout => 'section_with_default_sidebar'
  # end

  # def update
  #   @idea = Idea.find(params[:id])
  #   @idea.idea_list_tokens = params[:idea][:idea_list_tokens]
  #   if @idea.save!
  #     flash[:success] = "Successfully updated idea!"
  #     redirect_to @idea
  #   else
  #     render :action => 'show'
  #   end
  # end

  def show
    init_head
    init_default_sidebar
    render :layout => 'section_with_default_sidebar'
  end

  def users
    init_head
    @public_user_ideas = 
      @idea.public_user_ideas
           .page(params[:page])
           .per(@@items_per_page)
    init_default_sidebar
    render :layout => 'section_with_default_sidebar'
  end

  def followed_users
    init_head
    @public_user_ideas_of_users_followed_by_current_user = 
      @idea.public_user_ideas_of_users_followed_by(current_user)
           .page(params[:page])
           .per(@@items_per_page)
    init_default_sidebar
    render :layout => 'section_with_default_sidebar'
  end

  private

  def own_idea
    @idea = Idea.find(params[:id])
    redirect_to root_path unless not @idea.nil? and current_user?(@idea.owned_by)
  rescue Mongoid::Errors::DocumentNotFound
    redirect_to root_path
  end

  def own_idea_or_public
    @idea = Idea.find(params[:id])
    redirect_to root_path unless not @idea.nil? and current_user?(@idea.owned_by) || @idea.public?
  rescue Mongoid::Errors::DocumentNotFound
    redirect_to root_path
  end

  def init_head
    @user = current_user
    @user_idea = @user.user_idea_for_idea @idea
  end
end
