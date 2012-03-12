require 'spec_helper'

describe ResetPassword do

  before(:each) do
    @attr = {
      :email => 'user@example.com'
    }
  end

  it 'should have an email attribute' do
    reset_password = ResetPassword.new
    reset_password.should respond_to :email
  end

  it 'should have an persisted method' do
    reset_password = ResetPassword.new
    reset_password.should respond_to :persisted?
  end

  it 'should require an email' do
    no_name_user = ResetPassword.new(@attr.merge(:email => ''))
    no_name_user.should_not be_valid
  end

  it 'should reject invalid email addresses' do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = ResetPassword.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it 'should require an email of an existing user' do
    invalid_email_user = ResetPassword.new(@attr)
    invalid_email_user.should_not be_valid
    invalid_email_user.errors[:email].first.should == 'cannot be found in the database'
  end

  it 'should be valid' do
    Factory(:unique_user, :email => @attr[:email])
    valid_reset = ResetPassword.new(@attr)
    valid_reset.should be_valid
  end
end
