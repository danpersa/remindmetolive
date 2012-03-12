class ChangeResetedPassword
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :password, :password_confirmation, :password_reset_code

  validates :password, :presence     => true,
                       :confirmation => true,
                       :length       => { :within => 6..40 }

  validates :password_reset_code, :presence  => true

  def initialize(attributes = {})
      self.password = attributes[:password]
      self.password_confirmation = attributes[:password_confirmation]
      self.password_reset_code = attributes[:password_reset_code]
    end

  def persisted?
    false
  end
end
