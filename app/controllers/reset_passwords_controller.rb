class ResetPasswordsController < ApplicationController
  include EdgeAuth::Concerns::ResetPasswords
  layout 'one_section_narrow'
end