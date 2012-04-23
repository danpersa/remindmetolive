class DoneIdeasController < ApplicationController
  before_filter :authenticate
  
  def create
    @idea = Idea.find(params[:id])
    @idea.mark_as_done_by!(current_user)
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @idea = Idea.find(params[:id])
    @idea.unmark_as_done_by!(current_user)
    respond_to do |format|
      format.js
    end
  end
end
