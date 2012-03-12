require 'spec_helper'

describe ChangePassword do
  before(:each) do
    @user = Factory(:activated_user)
    @attr = {
      :password => 'password',
      :password_confirmation => 'password',
      :old_password => 'foobar'
    }
  end

  it 'should create a new valid instance given valid attributes' do
    change_password = ChangePassword.new(@attr)
    change_password.user_id = @user.id
    change_password.should be_valid
  end

  it_should_behave_like 'password validation' do
    let(:action) do
      @valid_object = ChangePassword.new(@attr)
      @valid_object.user_id = @user.id
    end
  end

  describe 'failure' do

    it 'should not be valid without an user_id' do
      change_password = ChangePassword.new(@attr)
      change_password.should_not be_valid
    end

    it 'should not be valid without an old_password' do
      change_password = ChangePassword.new(@attr.merge(:old_password => ''))
      change_password.should_not be_valid 
    end

    it 'should not be valid with wrong old_password' do
      change_password = ChangePassword.new(@attr.merge(:old_password => 'abc'))
      change_password.user_id = @user.id
      change_password.should_not be_valid
      change_password.errors.first[1].should == 'Old password must be filled in with your current password'
    end
  end
end
