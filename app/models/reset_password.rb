require 'validators/email_format_validator'

class ResetPassword
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :email

  validates :email, :presence     => true,
                    :email_format => true

  validate :email_must_belong_to_an_user

  def initialize(attributes = {})
    self.email = attributes[:email]
  end

  def email_must_belong_to_an_user
    errors.add(:email, "cannot be found in the database") if
      (not self.email.blank?) and User.find_by_email(self.email) == nil
  end

  def persisted?
    false
  end
end
