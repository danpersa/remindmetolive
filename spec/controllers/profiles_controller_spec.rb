require 'spec_helper'

describe ProfilesController do
  render_views

  before(:each) do
    @base_title = 'Remind me to live'
  end

  describe 'access control' do
    describe 'authentication' do
      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          user = FactoryGirl.create(:activated_user)
          get :edit, :user_id => user.id
        end
      end
  
      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          user = FactoryGirl.create(:activated_user)
          post :create, :user_id => user.id
        end
      end
    end
    
    describe 'the requested user is not the logged user' do
      before(:each) do
        @user = test_sign_in(FactoryGirl.create(:unique_user))
        @another_user = FactoryGirl.create(:unique_user, :email => 'other@yahoo.com')
      end
    
      it 'should not allow access for edit' do
        get :edit, :user_id => @another_user, :profile => @attr
        response.should redirect_to(user_profile_path(@user))
      end
      
      it 'should not allow access for create' do
        post :create, :user_id => @another_user, :profile => @attr
        response.should redirect_to(user_profile_path(@user))
      end
    end
    
    describe 'the user does not exist' do
      before(:each) do
        @user = test_sign_in(FactoryGirl.create(:unique_user))
      end
      
      it 'should not edit' do
        get :edit, :user_id => Moped::BSON::ObjectId('4f341be673d987547700ffff')
        response.should redirect_to(user_profile_path(@user))
      end
      
      it 'should not create' do
        post :create, :user_id => Moped::BSON::ObjectId('4f341be673d987547700ffff'),
             :profile => @attr
        response.should redirect_to(user_profile_path(@user))
      end
    end
  end

  describe 'GET edit' do

    before(:each) do
      @user = test_web_sign_in(FactoryGirl.create(:unique_user))
    end
    
    it_should_behave_like 'successful get request' do
      let(:action) do
        visit edit_user_profile_path(:user_id => @user.id)
        @title = @base_title + ' | Update public profile'
      end
    end
  end

  describe 'POST create' do

    before(:each) do
      @user = test_sign_in(FactoryGirl.create(:unique_user, :profile => nil))
      @attr = {:email => '', :name => '',
                 :location => '', :website => ''}
    end

    describe 'failure' do
      
      it 'should not create a profile with empty fields' do
        post :create, :user_id => @user.id, :profile => @attr
        user = User.find(@user.id)
        user.profile.should == nil
      end
      
      describe 'invalid email' do
      
        it 'should not create a profile' do
          post :create, :user_id => @user.id, 
                 :profile => @attr.merge({:email => 'dan'})
          user = User.find(@user.id)
          user.profile.should == nil
        end
        
        it 'should render the edit template' do
          post :create, :user_id => @user.id, 
               :profile => @attr.merge({:email => 'dan'})
          response.should render_template(:edit)
        end
      end
    end

    describe 'success' do
      
      it 'should create a profile' do
        post :create, :user_id => @user.id, 
               :profile => @attr.merge({:email => 'dan@yahoo.com'})
        user = User.find(@user.id)
        user.profile.should_not be_nil
      end
      
      describe 'successful creation of a profile' do
        it_should_behave_like 'redirect with flash' do
          let(:action) do
            post :create, :user_id => @user.id,
               :profile => @attr.merge({:email => 'dan@yahoo.com'})
            @notification = :success
            @message = /profile successfully updated/i
            @path = user_profile_path(@user)
          end
        end
      end
    end
  end
end
