require 'spec_helper'
require 'user_observer'

describe UserObserver do

  before do
    RemindMeToLive::Application.config.disable_registration_confirmation_mail = false
    @attr = {
      :username => 'ExampleUser',
      :email => 'user@example.com',
      :password => 'foobar',
      :password_confirmation => 'foobar'
    }
    ActionMailer::Base.deliveries = []
  end

  it 'should send a mail when the user is created' do
    User.create!(@attr)
    ActionMailer::Base.deliveries.should_not be_empty
  end

  it 'should not send a mail if validation fails' do
    User.create(@attr.merge :password_confirmation => 'foo')
    ActionMailer::Base.deliveries.should be_empty
  end

  after do
    RemindMeToLive::Application.config.disable_registration_confirmation_mail = false
  end
end
