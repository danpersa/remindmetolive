class UsersController < ApplicationController

  include RecaptchaHelper

  before_filter :authenticate, :except => [:show, :new, :create, :activate, :reset_password, :change_reseted_password]
  before_filter :activate_user, :except => [:show, :new, :create, :activate, :reset_password, :change_reseted_password]
  before_filter :existing_user, :only => [:show, :edit, :update, :destroy, :following, :followers, :ideas, :follow, :unfollow]
  before_filter :correct_user, :only => [:edit, :update, :ideas]
  before_filter :admin_or_correct_user, :only => :destroy
  before_filter :not_authenticate, :only => [:change_reseted_password]

  @@items_per_page = 10

  def index
    @user = current_user
    @title = "All users"
    @users = User.page(params[:page])
  end

  def show
    if current_user.id == @user.id
      @social_events = CreateIdeaSocialEvent.of_user(@user).limit @@items_per_page
    else
      @social_events = CreateIdeaSocialEvent.public_of_user(@user).limit @@items_per_page
    end
    # we store the location so we can be redirected here after reminder delete
    store_location
    store_current_page
    @title = @user.display_name
    init_default_sidebar
    render :layout => 'section_with_default_sidebar'
  end

  def new
    @auth_form_model = User.new
    @auth_form_options = {:builder => SupersizeFormBuilder}
    @title = "Sign up"
    render :layout => 'one_section_narrow'
  end

  def create
    @auth_form_options = {:builder => SupersizeFormBuilder}
    @auth_form_model = User.new(params[:user])

    unless verify_recaptcha(request.remote_ip, params)
      @title = 'Sign up'
      # we trigger the validation manually
      @auth_form_model.valid?
      @auth_form_model.errors[:recaptcha] = 'The CAPTCHA solution was incorrect. Please re-try'
      render :layout => 'one_section_narrow', :template => 'users/new'
      return
    end

    if @auth_form_model.save
      flash[:success] = "Please follow the steps from the email we sent you to activate your account!!"
      redirect_to signin_path
    else
      @title = "Sign up"
      render :new
    end
  end

  def edit
    @title = "Edit user"
    render :layout => 'settings_sections'
    # the user is searched in the existing_user before interceptor
  end

  def update
    # the user is searched in the existing_user before interceptor
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render :edit
    end
  end

  def destroy
    if (current_user?(@user))
      delete_own_account = true
    end
    # the user is searched in the existing_user before interceptor
    @user.destroy
    if (delete_own_account)
      flash[:success] = "Your account was successfully deleted!"
      redirect_to root_path
    else
      flash[:success] = "User destroyed."
      redirect_to users_path
    end
  end

  def following
    # the user is searched in the existing_user before interceptor
    @title = "Following"
    @users = @user.following # .page(params[:page])
    init_default_sidebar
    render :layout => 'section_with_default_sidebar'
  end

  def followers
    # the user is searched in the existing_user before interceptor
    @title = "Followers"
    @users = @user.followers #.page(params[:page])
    init_default_sidebar
    render :layout => 'section_with_default_sidebar'
  end

  def follow
    current_user.follow! @user
  end

  def unfollow
    current_user.unfollow! @user
  end

  def activate
    if signed_in?
      if !activated?
        deny_access("Please activate your account before before you sign in!")
        return
      else
       redirect_to current_user
       return
      end
    end
    activated_user = User.where('activation_code' => params[:activation_code]).first
    if activated_user != nil && !activated_user.activated?
      activated_user.activate!
      sign_in activated_user
      flash[:success] = "Welcome to Remind Me To Live!"
      redirect_to root_path
      return
    end
    if activated_user != nil && activated_user.activated?
      deny_access("Your account has already been activated!")
      return
    end
    redirect_to signin_path
  end

  # page displaying the ideas of the current user
  def ideas
    @user_ideas = @user.ideas_ordered_by_reminder_created_at
    # we store the location so we can be redirected here after idea delete
    store_location
    store_current_page
    init_default_sidebar
    render :layout => 'section_with_default_sidebar'
  end

  private 

  def existing_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless not @user.nil?
  end

  def correct_user
    redirect_to(root_path) unless current_user?(@user)
  end
  
  def admin_or_correct_user
    redirect_to(root_path) unless current_user.admin? or current_user?(@user)  
  end
end
