class UserObserver < Mongoid::Observer

  def after_create(user)
  	#return if (RemindMeToLive::Application.config.disable_registration_confirmation_mail == true)
    #UserMailer.registration_confirmation(user).deliver
  end
end