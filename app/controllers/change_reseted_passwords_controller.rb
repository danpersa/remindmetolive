class ChangeResetedPasswordsController < ApplicationController
  
  layout 'one_section_narrow'
  
  before_filter :not_authenticate
  
  def edit
    @change_reseted_password = ChangeResetedPassword.new({:password_reset_code => params[:id]})
    @user = User.find_by_password_reset_code(@change_reseted_password.password_reset_code)
    if deny_access_if_invalid_link?
      return
    end
    if deny_access_if_user_not_activated?
      return
    end
    if deny_access_if_reset_password_expired?
      return
    end
    @title = "Change Password"
  end

  def create
    # we create the change password object
    @change_reseted_password = ChangeResetedPassword.new(params[:change_reseted_password])
    # we look for a user with that password_reset_code
    @user = User.find_by_password_reset_code(@change_reseted_password.password_reset_code)
    # if we don't find an user with that password_reset_code
    if deny_access_if_invalid_link?
      return
    end
    if deny_access_if_user_not_activated?
      return
    end
    # the link has expired
    if deny_access_if_reset_password_expired?
      return
    end 
    # if the new password is valid
    if @change_reseted_password.valid?
      flash[:success] = "Your password was successfully changed!"
      # we update the user
      @user.updating_password = true
      @user.password = @change_reseted_password.password
      @user.password_confirmation = @change_reseted_password.password_confirmation
      # we don't let a password reset code to be used twice
      @user.password_reset_code = nil
      @user.reset_password_mail_sent_at = nil
      @user.save!(:validate => false)
      redirect_to signin_path
    else
      @title = "Change Password"
      render 'edit'
    end
  end
  
  private
  
  def deny_access_if_reset_password_expired?
    if @user.reset_password_expired?
      redirect_to reset_passwords_path, :notice => "Your reset password link has expired! Please use the reset password feature again!"
      return true
    end
    return false
  end
  
  def deny_access_if_invalid_link?
    if @user.nil?
      # maybe someone is trying to update another user's password
      deny_access("You don't have a valid reset password link!")
      return true
    end
    return false
  end
  
  def deny_access_if_user_not_activated?
    if !@user.activated?
      deny_access("You cannot reset password for an user that is not activated! Please activate the user first!")
      return true
    end
    return false
  end
end
