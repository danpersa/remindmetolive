require 'spec_helper'

describe ChangePasswordsController do
  render_views
  
  describe 'GET new' do
    before(:each) do
      @base_title = 'Remind me to live'
      @user = Factory(:activated_user)
    end
    
    describe 'success' do
      
      it_should_behave_like 'successful get request' do
        let(:action) do
          test_web_sign_in(@user)
          visit new_change_password_path
          @title = @base_title + ' | Change Password'
        end
      end
      
      it 'should render the new template' do
        test_sign_in(@user)
        get :new
        response.should render_template :new
      end
    end
    
    describe 'failure' do
      
      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          get :new
        end 
      end
    end
  end
  
  describe 'POST create' do
    before(:each) do
      @user = Factory(:activated_user)
      @attr = {
      :password => 'password',
      :password_confirmation => 'password',
      :old_password => 'foobar'
    }
    end
    
    describe 'success' do
      before(:each) do
        test_sign_in(@user)
      end
      
      it 'should change the password' do
        post :create, :change_password => @attr
        @user.reload
        @user.has_password?(@attr[:password]).should == true 
      end
      
      it_should_behave_like 'redirect with flash' do
        let(:action) do
          post :create, :change_password => @attr
          @notification = :success
          @message = /Your password was successfully changed!/
          @path = edit_user_path(@user)
        end
      end
    end
    
    describe 'failure' do
      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          post :create, :change_password => @attr
        end 
      end
      
      it 'should reject request with missing old password' do
        test_sign_in(@user)
        post :create, :change_password => @attr.merge(:old_password => '')
        response.should render_template :new
      end
      
      it 'should reject request with wrong old password' do
        test_sign_in(@user)
        post :create, :change_password => @attr.merge(:old_password => 'wrong')
        response.should render_template :new
      end
      
      it 'should validate password confirmation' do
        test_sign_in(@user)
        post :create, :change_password => @attr.merge(:password_confirmation => 'another')
        response.should render_template :new
      end
      
      it 'should validate password' do
        test_sign_in(@user)
        post :create, :change_password => @attr.merge(:password => 'short', 
              :password_confirmation => 'short')
        response.should render_template :new
      end
    end
  end
end
