require 'spec_helper'

describe UserMailer do
  let :user do
    FactoryGirl.build :pending_user
  end

  describe 'send registration confirmation' do
    before(:each) do
      ActionMailer::Base.deliveries = []
      @email = UserMailer.registration_confirmation(user).deliver
    end

    it 'should send an email' do
      ActionMailer::Base.deliveries.should_not be_empty
    end

    it 'should be sent to the correct user' do
      @email.to.should == [user.email]
    end

    it 'should have the correct subject' do
      @email.subject.should == 'Registered'
    end

    it 'should contain the correct activation code' do
      @email.body.encoded.should match(user.activation_code)
    end
  end
  
  describe 'send reset password' do
    before(:each) do
      ActionMailer::Base.deliveries = []
      @email = user.reset_password_with_email
    end

    it 'should send an email' do
      ActionMailer::Base.deliveries.should_not be_empty
    end

    it 'should be sent to the correct user' do
      @email.to.should == [user.email]
    end

    it 'should have the correct subject' do
      @email.subject.should == 'Reset Password'
    end

    it 'should containt the correct activation code' do
      @email.body.encoded.should match(user.password_reset_code)
    end
  end
end
