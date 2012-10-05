class SessionsController < ApplicationController
  include EdgeAuth::Concerns::Sessions

  layout 'one_section_narrow'
end
