class UserObserver < Mongoid::Observer

  def after_create(user)
    UserMailer.registration_confirmation(user).deliver
  end
end