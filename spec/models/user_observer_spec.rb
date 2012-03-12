require 'spec_helper'
require 'user_observer'

describe UserObserver do

  before do
    Mongoid.observers = UserObserver
    Mongoid.instantiate_observers
    @attr = {
      :username => 'ExampleUser',
      :email => 'user@example.com',
      :password => 'foobar',
      :password_confirmation => 'foobar'
    }
    ActionMailer::Base.deliveries = []
  end

  after do
    User.observers.disable(:all)
  end

  it 'should send a mail when the user is created' do
    User.create!(@attr)
    ActionMailer::Base.deliveries.should_not be_empty
  end

  it 'should not send a mail if validation fails' do
    User.create(@attr.merge :password_confirmation => 'foo')
    ActionMailer::Base.deliveries.should be_empty
  end
end
