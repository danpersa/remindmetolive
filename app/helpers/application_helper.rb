module ApplicationHelper
  include EdgeLayouts::ApplicationHelper

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

  def sidebar_idea_lists
    IdeaList.owned_by current_user
  end

  def init_feeds_table
    @social_events = SocialEvent.own_or_public_of_users_followed_by(current_user)
                                .without(:users)
                                .page(params[:page]).per(RemindMeToLive::Application.config.items_per_page)
  end

  def init_default_sidebar
    @followers = current_user.followers.limit 15
    @following = current_user.following.limit 15
    @idea_lists = current_user.idea_lists
  end

  def init_reminders_table_of user
    @reminders = user.reminders_for_logged_user(current_user)
                     .includes(:privacy).page(params[:page])
                     .per(RemindMeToLive::Application.config.items_per_page)
  end
end
