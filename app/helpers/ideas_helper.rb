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

  def own_idea
    @idea = Idea.find(params[:id])
    redirect_to root_path unless not @idea.nil? and current_user?(@idea.owned_by)
  rescue Mongoid::Errors::DocumentNotFound
    redirect_to root_path
  end

  def own_idea_or_public
    @idea = Idea.find(params[:id])
    redirect_to root_path unless not @idea.nil? and current_user?(@idea.owned_by) or @idea.public?
  rescue Mongoid::Errors::DocumentNotFound
    redirect_to root_path
  end
end