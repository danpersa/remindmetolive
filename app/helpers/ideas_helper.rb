module IdeasHelper

  def details_tab_active_class
    return 'active' if "#{params[:controller].parameterize}_#{params[:action].parameterize}" == 'ideas_show'
  end

  def users_tab_active_class
    return 'active' if "#{params[:controller].parameterize}_#{params[:action].parameterize}" == 'ideas_users'
  end

  def followed_users_tab_active_class
    return 'active' if "#{params[:controller].parameterize}_#{params[:action].parameterize}" == 'ideas_followed_users'
  end
end