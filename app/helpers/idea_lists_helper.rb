module IdeaListsHelper

  def idea_list_active_class page_idea_list, current_idea_list
    unless page_idea_list.nil?
      if page_idea_list.id == current_idea_list.id
        return 'active'
      end
    end
  end

  def idea_lists_active_class
    return 'active' if "#{params[:controller].parameterize}_#{params[:action].parameterize}" == 'idea_lists_index'
  end
end