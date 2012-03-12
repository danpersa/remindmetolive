class Profile
  include Mongoid::Document
  field :name, :type => String
  field :email, :type => String
  field :location, :type => String
  field :website, :type => String

  validates_length_of         :name, maximum: 50

  validates_length_of         :email, maximum: 255
  validates_format_of         :email, with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, allow_blank: true

  validates_length_of         :location, maximum: 100
  validates_length_of         :website, maximum: 100

  embedded_in :user

  def empty_profile?
    return true if self.name.empty? and self.email.empty? and self.location.empty? and self.website.empty?
    return false
  end
end
