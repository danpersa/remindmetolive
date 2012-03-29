module ApplicationHelper

  @@items_per_page = 100

  # return a title on a per-page basis
  def title
    base_title = "Remind me to live"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end

  def logo
    image_tag("remindmetolive.png", :alt => "Remind me to live", :class => "round")
  end

  def pluralize_without_numbers(count, one, many)
    pluralize(count, one, many)[count.to_s.length + 1..pluralize(count, one, many).length]
  end

  def has_prev_page(page)
    return true unless page <= 1
  end

  def has_next_page(next_feed_item)
    return true unless next_feed_item.nil?
  end

  def get_page
    @page = params[:page].nil? ? 1 : params[:page].to_i
  end

  def pagination(collection, items_per_page)
    @page = get_page
    r = collection.offset((@page - 1) * items_per_page).limit(items_per_page + 1).all
    @has_prev_page = has_prev_page(@page)
    next_feed_item = r[items_per_page]
    r = r[0..items_per_page - 1]
    @has_next_page = has_next_page(next_feed_item)
    return r
  end

  def errors_for_field(object, field)
    html = String.new
    html << "<div id='#{object.class.name.underscore.downcase}_#{field}_errors' class='errors'>\n"
    unless object.errors.blank?
      html << "\t\t<ul>\n"
      object.errors[field].each do |error|
        html << "\t\t\t<li>#{error}</li>\n" 
      end
      html << "\t\t</ul>\n"
    end
    html << "\t</div>\n"
    return html.html_safe
  end

  def remote?
    if (@remote == true)
      return true
    end 
    return false
  end

  def hide_buttons?
    if (not @hide_buttons.nil?) and (@hide_buttons == true)
      return true
    end 
    false
  end

  def ajax_form?
    if @ajax_form == true
      return true
    end 
    return false
  end

  def reminders_form_url
    logger.debug "reminders form url : "
    logger.debug @reminders_form_url
    if @reminders_form_url.nil?
      return reminders_path
    end
    @reminders_form_url
  end

  def remind_me_too_location
    if @remind_me_too_location.nil?
      return '0'
    end
    @remind_me_too_location
  end

  def dialog_height
    if @dialog_height.nil?
      return "220";
    end
    return @dialog_height
  end

  def submit_button_name
    if (@submit_button_name.blank?)
      return "Post"
    end
    @submit_button_name
  end

  def respond_with_remote_form template=nil
    respond_to do |format|
      format.html {
        if template.nil?
          render :layout => 'layouts/one_section_narrow'
        else
          render :layout => 'layouts/one_section_narrow', :template => template
        end
      }
      format.js {
        @hide_buttons = true
        @remote = true
        @ajax_form = true
        unless template.nil?
          render :template => template
        end
      }
    end
  end

  def file_exists?(path)
    if (not path.blank?) and FileTest.exists?("#{::Rails.root.to_s}/#{path}")
      return true
    end
    false
  end

  def sidebar_idea_lists
    IdeaList.owned_by current_user
  end

  def js_exists?(name)
    return true if file_exists? "app/assets/javascripts/#{name}.js" or 
      file_exists? "app/assets/javascripts/#{name}.js.coffee"
    false
  end

  def js_for_controller_exists?
    js_exists?(params[:controller].parameterize)
  end

  def js_for_action_exists?
    js_exists?("#{params[:controller].parameterize}_#{params[:action].parameterize}")
  end

  def url_to_hash url
    path_hash = Rails.application.routes.recognize_path url
    params = url.split('?')[1]
    unless (params.nil?)
      path_hash = path_hash.merge(Rack::Utils.parse_nested_query(params))
    end
    path_hash[:page] = path_hash["page"]
    return path_hash
  end

  def init_feeds_table1
    @social_events = SocialEvent.own_or_public_of_users_followed_by(current_user).without(:users).page(@page).per(@@items_per_page)
  end

  def init_default_sidebar
    @followers = current_user.followers.limit 15
    @following = current_user.following.limit 15
    @idea_lists = current_user.idea_lists
  end

  def init_reminders_table_of user
    @reminders = user.reminders_for_logged_user(current_user).includes(:privacy).page(@page).per(@@items_per_page)
  end

  def display_all_error_messages(object, method)
    list_items = object.errors[method].map { |msg| msg }
    list_items.join(',').html_safe
  end

  def display_first_error_message(object, method)
    list_items = object.errors[method].map { |msg| msg }
    list_items.first.html_safe
  end
end
