class IdeaFormsController < ApplicationController
  layout 'section_with_default_sidebar'
  before_filter :authenticate

  before_filter :own_idea_or_public_if_exists, :only => [:create]
  before_filter :own_idea_or_public, :only => [:show]

  respond_to :html, :js

  def create
    @idea_form = IdeaForm.new current_user
    idea_form_params = params[:idea_form]
    idea_form_params = params[:existing_idea_form] if idea_form_params.nil?

    respond_to do |format|
      if @idea_form.submit idea_form_params
        flash[:success] = "Idea created!"
        format.html {
          redirect_back_or root_path
        }
      else
        format.html {
          log_errors @idea_form
          init_feeds_table
          @user = current_user
          init_default_sidebar
          render 'pages/home'
        }
      end
      format.js {
        respond_with_remote_form
        respond_with(@idea_form, :layout => !request.xhr?)
      }
    end
  end

  def show
    @idea_form = IdeaForm.new current_user
    @dialog_content = 'idea_forms/form_with_idea'
    if (not @idea.nil?) and current_user.has_idea?(@idea)
      #logger.info  "idea is shared"
      user_idea = current_user.user_idea @idea
      if user_idea.reminder_date.nil?
        @title = "Create reminder"
      else
        @title = "Modify reminder"
        @idea_form.repeat = user_idea.repeat
        @idea_form.reminder_on = user_idea.reminder_on
      end
    else
      logger.info  "idea is not shared"
      @title = "Remind me too"
    end  
    @submit_button_name = "Create reminder"
    respond_with_remote_form 'idea_forms/show'
  end


  private

  def own_idea_or_public_if_exists
    return if params[:idea_id].nil?
    @idea = Idea.find(params[:idea_id])
    redirect_to idea_lists_path unless not @idea.nil? and current_user?(@idea.owned_by) || @idea.public?
  end


end