class ChangePassword
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :password, :password_confirmation, :old_password, :user_id

  validates :password, :presence     => true,
                       :confirmation => true,
                       :length       => { :within => 6..40 }

  validates :old_password, :presence     => true

  validates :user_id, :presence          => true

  validate  :old_password_match

  def initialize(attributes = {})
    self.password = attributes[:password]
    self.password_confirmation = attributes[:password_confirmation]
    self.old_password = attributes[:old_password]
  end

  def persisted?
    false
  end

  private

  def old_password_match
     return if self.user_id.nil?
    user = User.find(self.user_id)
    errors.add(:old_password, "Old password must be filled in with your current password") if
      !user.nil? and !self.old_password.empty? and !user.has_password?(self.old_password)
  end
end
