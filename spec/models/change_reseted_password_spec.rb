require 'spec_helper'

describe ChangeResetedPassword do
  before(:each) do
    @attr = {
      :password => 'password',
      :password_confirmation => 'password',
      :password_reset_code => 'abcdefg'
    }
  end

  it 'should create a new valid instance given valid attributes' do
    change_reseted_password = ChangeResetedPassword.new(@attr)
    change_reseted_password.should be_valid
  end

  it_should_behave_like 'password validation' do
    let(:action) do
      @valid_object = ChangeResetedPassword.new(@attr)
    end
  end
end
