class ErrorsController < ApplicationController
  def routing
    render 'public/404.html', :status => 404
  end
end
