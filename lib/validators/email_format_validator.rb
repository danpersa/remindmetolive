class EmailFormatValidator < ActiveModel::EachValidator
  
  def validate_each(object, attribute, value)
    email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    unless value.blank? or value =~ email_regex
      object.errors[attribute] << (options[:message] || "is not formatted properly") 
    end
  end
end