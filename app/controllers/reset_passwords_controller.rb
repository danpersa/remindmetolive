class ResetPasswordsController < ApplicationController
  include EdgeAuth::Concerns::ResetPasswordsController
  
  layout 'one_section_narrow'
end