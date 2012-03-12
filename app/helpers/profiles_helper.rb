module ProfilesHelper

  def profiles_edit_active_class
    return 'active' if "#{params[:controller].parameterize}_#{params[:action].parameterize}" == 'profiles_edit'
  end
end