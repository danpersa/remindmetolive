require 'spec_helper'

describe User do

  before(:each) do
    @attr = {
      :username => 'Example',
      :email => 'user@example.com',
      :password => 'foobar',
      :password_confirmation => 'foobar'
    }
  end

  describe 'field validation' do
    describe 'username field' do

      context 'when validating name presence' do

        let(:user) do
          FactoryGirl.build(:simple_user, username: nil)
        end

        before do
          user.valid?
        end

        it 'should be provided' do
          user.errors[:username].first.should == 'can\'t be blank'
        end
      end

      context 'when validating username uniqueness' do
        let(:user) do
          FactoryGirl.build(:simple_user)
        end

        before do
          FactoryGirl.create(:simple_user)
          user.valid?
        end

        it 'should be unique' do
          user.errors[:username].should == [ 'is already taken' ]
        end
      end

      describe 'when validating length' do
        context 'too short' do
          let(:user) do
            FactoryGirl.build(:simple_user, username: 'shor')
          end

          before do
            user.valid?
          end

          it 'should be longer than 5 characters' do
            user.errors[:username].should == [ 'is too short (minimum is 5 characters)' ]
          end
        end

        context 'too long' do
          let(:user) do
            FactoryGirl.build(:simple_user, username: 'a' * 51)
          end

          before do
            user.valid?
          end

          it 'should be shorter than 25 characters' do
            user.errors[:username].should == [ 'is too long (maximum is 25 characters)' ]
          end
        end
      end
    end

    describe 'password field' do

      it_should_behave_like 'password validation' do
        let(:action) do
          @valid_object = FactoryGirl.build(:simple_user)
        end
      end
    end
  end

  describe 'admin attribute' do

    let(:user) do
      FactoryGirl.build(:simple_user)
    end

    it 'should respond to admin' do
      user.should respond_to(:admin)
    end

    it 'should not be an admin by default' do
      user.should_not be_admin
    end

    it 'should be convertible to an admin' do
#      @user.toggle!(:admin)
#      @user.should be_admin
    end
  end

  describe 'idea_lists_count field' do
    let(:user) do
      FactoryGirl.build(:simple_user)
    end

    it 'should exist' do
      user.should respond_to :idea_lists_count
    end
  end
end
