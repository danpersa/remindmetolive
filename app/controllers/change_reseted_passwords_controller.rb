class ChangeResetedPasswordsController < ApplicationController
  include EdgeAuth::Concerns::ChangeResetedPasswordsController
  
  layout 'one_section_narrow'
end
