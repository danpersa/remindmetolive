class UserMailer < ActionMailer::Base
  default :from => "register@remindmetolive.com"

  def registration_confirmation(user)
    @user = user
    #attachments["rails.png"] = File.read("#{Rails.root}/public/images/rails.png")
    mail = mail(:to => "#{user.username} <#{user.email}>", :subject => "Registered")
    mail
  end

  def reset_password(user)
    @user = user
    mail = mail(:to => "#{user.username} <#{user.email}>", :subject => "Reset Password")
    mail
  end
end
