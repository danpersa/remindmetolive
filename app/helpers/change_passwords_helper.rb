module ChangePasswordsHelper

  def change_passwords_active_class
    return 'active' if "#{params[:controller].parameterize}_#{params[:action].parameterize}" == 'change_passwords_new'
  end
	
end