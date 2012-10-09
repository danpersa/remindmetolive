class SessionsController < ApplicationController
  include EdgeAuth::Concerns::SessionsController

  layout 'one_section_narrow'
end
