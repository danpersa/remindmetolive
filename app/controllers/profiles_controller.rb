class ProfilesController < ApplicationController
  before_filter :authenticate, :only => [:edit, :create, :update]
  before_filter :correct_user, :only => [:edit, :create, :update]
  
  def edit
    @profile = current_user.profile
    if @profile.nil?
      @profile = Profile.new
    end
    @title = 'Update Public Profile'
    render :layout => 'settings_sections'
  end

  def create
    @profile = Profile.new(params[:profile])
    @profile.user = current_user
    save_profile
  end

  private
  
  def save_profile
    if @profile.empty_profile? or @profile.save
      redirect_to_edit_with_flash
      return
    else
      @title = 'Update Public Profile'
      render :action => :edit, :layout => 'settings_sections'
    end
  end
  
  def redirect_to_edit_with_flash
    flash[:success] = 'Profile successfully updated'
    redirect_to edit_user_profile_path(current_user)
  end

  def correct_user
    @user = User.find(params[:user_id])
    redirect_to(edit_user_profile_path(current_user)) unless current_user?(@user)
  rescue Mongoid::Errors::DocumentNotFound
    redirect_to(edit_user_profile_path(current_user))
  end
end
