module SessionsHelper

  def sign_in(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    self.current_user = user
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= user_from_remember_token
    if @current_user.nil?
      return nil
    end
    return @current_user
  end

  def signed_in?
    !current_user.nil?
  end
  
  def activated?
    !current_user.nil? and current_user.activated? 
  end

  def sign_out
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  def current_user?(user)
    user == current_user
  end
  
  def current_user_id?(user_id)
    user_id == current_user.id
  end
  
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end
  
  def authenticate
    deny_access("Please sign in to access this page.") unless signed_in?
  end
  
  def not_authenticate
    redirect_to_root_path_with_notice("You must not be signed in in order to do this action!") if signed_in?
  end
  
  def activate_user
    redirect_to_signin_path_with_notice("Please activate your account before before you sign in!") unless activated?
  end

  def deny_access(message)
    store_location
    redirect_to_signin_path_with_notice message
  end
  
  def redirect_to_signin_path_with_notice(notice)
    redirect_to signin_path, :notice => notice
  end
  
  def redirect_to_root_path_with_notice(notice)
    redirect_to root_path, :notice => notice
  end
  
  def store_current_page
    session[:current_page] = request.fullpath
  end
  
  def current_page
    session[:current_page]
  end

private

  def user_from_remember_token
    User.authenticate_with_salt(*remember_token)
  end

  def remember_token
    cookies.signed[:remember_token] || [nil, nil]
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def clear_return_to
    session[:return_to] = nil
  end
end
