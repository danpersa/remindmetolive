class ChangeResetedPasswordsController < ApplicationController
  include EdgeAuth::Concerns::ChangeResetedPasswords
  
  layout 'one_section_narrow'
end
