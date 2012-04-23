class IdeaListsController < ApplicationController
  before_filter :authenticate, :only => [:index, :show, :new, :create, :edit, :update, :destroy, :add_idea]
  before_filter :own_idea_list, :only => [:show, :edit, :update, :destroy, :add_idea]
  before_filter :own_idea_or_public, :only => [:add_idea]

  respond_to :html, :js

  def index
    @user = current_user
    @idea_list = IdeaList.new
    @edit_idea_list = IdeaList.new
    @edit_idea_list.id = 0;
    @edit_idea_list.name = "";
    @title = "My lists of ideas"
    respond_to do |format|
      format.html {
        init_idea_lists_with_pagination
        init_default_sidebar
        render :layout => 'section_with_default_sidebar'
      }
      format.json {
        @idea_lists = IdeaList.where("lower(name) like lower(?)", "%#{params[:q]}%").owned_by(current_user)
        render :json => @idea_lists.map(&:attributes)
      }
      format.js {
        init_idea_lists_with_pagination
      }
    end
  end

  def show
    @user = current_user
    @user_ideas = current_user.ideas_from_list_ordered_by_reminder_created_at(@idea_list)
                              .page(params[:page])
                              .per(RemindMeToLive::Application.config.items_per_page)
    @action = "show"
    @title = "Show idea list"
    # we store the location so we can be redirected here after idea delete
    store_location
    init_default_sidebar
    render :layout => 'section_with_default_sidebar'
  end

  def new
    @user = current_user
    @idea_list = IdeaList.new
    @title = "Create list of ideas"
    respond_with_remote_form
  end

  def create
    @idea_list = current_user.create_idea_list(params[:idea_list][:name])

    respond_to do |format|
      if @idea_list.valid?
        flash[:success] = "Idea list successfully created"
        format.html {
          redirect_to idea_lists_path
        }
        format.js {
          init_idea_lists_with_pagination
          respond_with_remote_form
          respond_with(@idea_list, :layout => !request.xhr?)
        }
      else
        format.html {
          @title = "Create idea list"
          respond_with_remote_form 'idea_lists/new'
        }
        format.js {
          respond_with_remote_form
          respond_with(@idea_list, :layout => !request.xhr?)
        }
      end
    end
  end

  def edit
    @user = current_user
    @title = "Update list of ideas"
    respond_with_remote_form
  end

  def update
    respond_to do |format|
      # the idea list is searched in the own_idea_list before interceptor
      if @idea_list.update_attributes params[:idea_list]
        flash[:success] = "List of ideas successfully updated"
        format.html {
          redirect_to idea_lists_path
        }
        format.js {
          init_idea_lists_with_pagination
          respond_with_remote_form
          respond_with( @idea_list, :layout => !request.xhr? )
        }
      else
        format.html {
          @title = "Update list of ideas"
          respond_with_remote_form 'idea_lists/edit'
        }
        format.js {
          respond_with_remote_form
          respond_with( @idea_list, :layout => !request.xhr? )
        }
      end
    end
  end

  def destroy
    respond_to do |format|
      if current_user.remove_idea_list @idea_list
        flash[:success] = "Idea list successfully deleted"
        format.html {
          redirect_to idea_lists_path
        }
      else
        flash[:notice] = "Idea list was not successfully deleted"
        format.html {
          redirect_to idea_lists_path
        }
      end
      format.js {
        init_idea_lists_with_pagination
      }
    end
  end

  def add_idea
    respond_to do |format|
      if @idea_list.add_idea_as @idea, Privacy::Values[:public]
        format.html { redirect_to idea_lists_path(@idea_list) }
      elsif
        format.html { redirect_to idea_lists_path }
      end
      format.js
    end
  end

  private

  def init_idea_lists_with_pagination
    @idea_lists_paginated =  current_user.idea_lists.page(params[:page])
                                          .per(RemindMeToLive::Application.config.items_per_page)
  end

  def own_idea_or_public
    @idea = Idea.find(params[:idea_id])
    redirect_to idea_lists_path unless not @idea.nil? and current_user?(@idea.owned_by) || @idea.public?
  end

  def own_idea_list
    @idea_list = current_user.idea_list_with_id(params[:id])
    redirect_to idea_lists_path unless not @idea_list.nil? and current_user?(@idea_list.user)
  end

end
