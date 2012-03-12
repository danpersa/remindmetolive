class ChangePasswordsController < ApplicationController
  before_filter :authenticate
  
  def new
    @change_password = ChangePassword.new
    @title = 'Change Password'
    render :layout => 'settings_sections'
  end

  def create
    # we create the change password object
    @change_password = ChangePassword.new(params[:change_password])
    # we set the user
    @change_password.user_id = current_user.id
    # if the new password is valid
    if @change_password.valid?
      @user = current_user
      # we update the user
      @user.updating_password = true
      @user.password = @change_password.password
      @user.password_confirmation = @change_password.password_confirmation
      # we don't let a password reset code to be used twice
      @user.save!(:validate => false)
      redirect_to edit_user_path(@user)
      flash[:success] = 'Your password was successfully changed!'
    else
      @title = 'Change Password'
      render :action => :new, :layout => 'settings_sections'
    end
  end
end
