require 'spec_helper'

describe UsersController do
  render_views

  before(:each) do
    # Define @base_title here.
    @base_title = 'Remind me to live'
  end

  describe 'access control' do

    describe 'authentication' do
      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          post :index
        end
      end

      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          get :show, :id => 1
        end
      end

      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          post :update, :id => 1
        end
      end

      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          delete :destroy, :id => 1
        end
      end

      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          post :follow, :id => 1
        end
      end

      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          delete :unfollow, :id => 1
        end
      end

      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          get :following
        end
      end

      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          get :followers
        end
      end
    end
  end


  describe 'GET index' do

    describe 'for signed-in users' do

      before(:each) do
        @user = test_web_sign_in(FactoryGirl.create(:unique_user))
        second = FactoryGirl.create(:unique_user)
        third  = FactoryGirl.create(:unique_user)
        @users = [@user, second, third]
      end
      
      it_should_behave_like 'successful get request' do
        let(:action) do
          visit users_path
          @title = @base_title + ' | All users'
        end
      end

      it 'should have an element for each user' do
        visit users_path
        @users[0..2].each do |user|
          page.should have_selector('a', :text => user.display_name)
        end
      end

      it 'should paginate users' do
        11.times do
          @users << FactoryGirl.create(:unique_user)
        end
        visit users_path
        page.should have_selector('ul.pagination')
        page.should have_link('2')
      end
    end
  end

  describe 'GET new' do
    
    it_should_behave_like 'successful get request' do
      let :action do
        visit new_user_path
        @title = @base_title + ' | Sign up'
      end
    end
  end

  describe 'GET show' do

    before(:each) do
      @user = test_web_sign_in(FactoryGirl.create(:unique_user))
    end
    
    it_should_behave_like 'successful get request' do
      let :action do
        visit user_path @user
        @title = @base_title + ' | ' + @user.display_name
      end
    end

    it 'should include the user\'s display name' do
      visit user_path(@user)
      page.should have_selector 'div.profile-avatar-name>a',
                                :text => @user.display_name
    end

    it 'should have a profile image' do
      visit user_path(@user)
      page.should have_selector('div>img.gravatar')
    end

    describe 'social events table' do
      before do
        @social_events = []
        11.times do |index|
          idea = FactoryGirl.create :idea, :created_by => @user,
                                :owned_by => @user,
                                :content => 'Baz quux' + index.to_s
          @social_events << FactoryGirl.create(:create_idea_social_event, :created_by => @user,
                                             :idea => idea)
        end
        visit user_path(@user)
      end

      it 'should show the social events' do
        index = 0
        @social_events.each do |social_event|
          page.should have_selector('strong', :text => social_event.idea.content) if index < 10
          index += 1
        end
      end
      
      it 'should paginate the social events' do
          page.should have_selector('ul.pagination')
          page.should have_link('2')
      end
    end
    
    context 'social events privacies' do
      before(:each) do
        @private_privacy = Privacy::Values[:private]
        @public_idea = FactoryGirl.create :idea, :created_by => @user,
                                :owned_by => @user,
                                :content => 'Foo bar',
                                :privacy => Privacy::Values[:public]
        @public_social_event = FactoryGirl.create(:create_idea_social_event, :created_by => @user,
                                                                  :idea => @public_idea)
        @private_idea = FactoryGirl.create :idea, :created_by => @user,
                                :owned_by => @user,
                                :content => 'Baz quux',
                                :privacy => Privacy::Values[:private]
        @private_social_event = FactoryGirl.create :create_idea_social_event, :created_by => @user,
                                                                   :idea => @private_idea,
                                                                   :privacy => Privacy::Values[:private]
      end

      context 'own profile' do
        before do
          visit user_path(@user)
        end

        it 'should show own private social events' do
          page.should have_selector('strong', :text => @private_idea.content)
        end

        it 'should show own public social events' do
          page.should have_selector('strong', :text => @public_idea.content)
        end
      end

      context 'other user\'s profile' do
        before do
          other_user = FactoryGirl.create(:unique_user)
          test_web_sign_in(other_user)
          visit user_path(@user)
        end

        it 'should show the user\'s public social events' do
          page.should have_selector('strong', :text => @public_idea.content)
        end

        it 'should not show other user\'s private social events' do
          page.should_not have_selector('strong', :text => @private_idea.content)
        end
      end
    end
  end

  describe 'POST create' do

    describe 'failure' do

      before(:each) do
        @attr = { :username => '', :email => '', :password => '',
                  :password_confirmation => '' }
      end

      it 'should not create a user' do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

      it 'should render the new page' do
        post :create, :user => @attr
        response.should render_template :new
      end
      
      it 'should not send any mail' do
        ActionMailer::Base.deliveries = []
        post :create, :user => @attr
        ActionMailer::Base.deliveries.should be_empty
      end
      
      it 'should validate the password' do
        @attr = { :username => 'New Name', :email => 'user@example.org',
                  :password => 'barbaz', :password_confirmation => 'barbaz1' }
        post :create, :user => @attr
        response.should render_template :new
      end
    end

    describe 'success' do

      before(:each) do
        @attr = { :username => 'New User', :email => 'user@example.com',
                  :password => 'foobar', :password_confirmation => 'foobar' }
      end

      it 'should create a user' do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it 'should redirect to the signin page' do
        post :create, :user => @attr
        response.should redirect_to(signin_path)
      end

      it 'should have a welcome message' do
        post :create, :user => @attr
        flash[:success].should =~ /please follow the steps from the email we sent you to activate your account/i
      end

      it 'should NOT sign the user in' do
        post :create, :user => @attr
        controller.should_not be_signed_in
      end

      describe 'mail sending after registration' do
        before do
          RemindMeToLive::Application.config.disable_registration_confirmation_mail = false
          ActionMailer::Base.deliveries = []
        end

        it 'should send registration confirmation any mail' do
          post :create, :user => @attr
          ActionMailer::Base.deliveries.should_not be_empty
          email = ActionMailer::Base.deliveries.last
          email.to.should == [@attr[:email]]
        end

        after do
          RemindMeToLive::Application.config.disable_registration_confirmation_mail = true
        end
      end
    end
  end

  describe 'GET edit' do

    describe 'security' do
      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          get :edit, :id => 1
        end
      end

      it 'should deny access if wrong user' do
        @user = FactoryGirl.create(:unique_user)
        test_sign_in(@user)
        wrong_user = FactoryGirl.create(:unique_user)
        get :edit, :id => wrong_user
        response.should redirect_to(root_path)
      end
    end

    describe 'success' do
      before(:each) do
        user = FactoryGirl.create(:unique_user)
        test_web_sign_in(user)
        visit edit_user_path(user)
      end
      
      it_should_behave_like 'successful get request' do
        let(:action) do
          @title = @base_title + ' | Edit user'
        end
      end
  
      it 'should have a link to change the Gravatar' do
        page.should have_link('change')
      end
    end
  end

  describe 'PUT update' do

    before(:each) do
      @user = FactoryGirl.create(:activated_user)
      test_sign_in(@user)
    end

    describe 'failure' do

      before(:each) do
        @attr = { :email => '', :username => '' }
      end

      context 'when blank username' do

        it 'should render the edit page' do
          put :update, :id => @user.id, :user => @attr.merge(:email => 'danix@yahoo.com')
          response.should render_template :edit
        end
      end

      context 'when blank email' do
        it 'should render the edit page' do
          put :update, :id => @user.id, :user => @attr.merge(:username => 'danix')
          response.should render_template :edit
        end
      end      

    end

    describe 'success' do

      before(:each) do
        @attr = { :username => 'New Name', :email => 'user@example.org',
                  :password => 'barbaz', :password_confirmation => 'barbaz' }
      end

      it 'should change the user\'s attributes' do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.username.should  == @attr[:username]
        @user.email.should == @attr[:email]
      end
      
      it 'should not change the user\'s password' do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.has_password?('foobar').should == true
      end

      it 'should redirect to the user show page' do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end

      it 'should have a flash message' do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end
    end
  end

  describe 'authentication of edit/update pages' do

    before(:each) do
      @user = FactoryGirl.create(:unique_user)
    end

    describe 'for non-signed-in users' do

      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          get :edit, :id => @user
        end
      end

      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          put :update, :id => @user, :user => {}
        end
      end
    end

    describe 'for signed-in users' do

      before(:each) do
        wrong_user = FactoryGirl.create(:unique_user)
        test_sign_in(wrong_user)
      end

      it 'should require matching users for edit' do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end

      it 'should require matching users for update' do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
  end

  describe 'DELETE destroy' do

    before(:each) do
      @user = FactoryGirl.create(:unique_user)
    end

    describe 'as a non-admin user' do
      it 'should protect the page if the user tries to delete other user\'s account' do
        test_sign_in(@user)
        other_user = FactoryGirl.create(:unique_user)
        delete :destroy, :id => other_user.id
        response.should redirect_to(root_path)
      end
      
      it 'should allow access if the user tries to delete his own account' do
        test_sign_in(@user)
        delete :destroy, :id => @user.id
        response.should redirect_to(root_path)
      end
    end

    describe 'as an admin user' do

      before(:each) do
        admin = FactoryGirl.create(:user, :email => 'admin@example.com', :admin => true)
        test_sign_in(admin)
      end

      it 'should destroy the user' do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it 'should redirect to the users page' do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end
    end
  end

  describe 'follow pages' do
    describe 'when not signed in' do
      
      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          get :following, :id => 1
        end
      end
      
      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          get :followers, :id => 1
        end
      end
    end
    
    describe 'when signed in' do
      before(:each) do
        @user = test_web_sign_in(FactoryGirl.create(:unique_user))
        @other_user = FactoryGirl.create(:unique_user)
        @user.follow!(@other_user)
      end
      
      it 'should show user following' do
        visit user_path(@user) + '/following'
        page.should have_link(@other_user.display_name)
      end
      
      it 'should show user followers' do
        visit user_path(@other_user) + '/following'
        page.should have_link(@user.display_name)
      end
    end
  end

  describe 'GET activate' do
    
    before(:each) do
      @user = FactoryGirl.create(:unique_user)
    end
    
    describe 'when signed in' do
      it 'should redirect to profile if correct activation code' do
        test_sign_in(@user)
        get :activate, :activation_code => @user.activation_code
        response.should redirect_to(users_path + "/#{@user.id}")
      end
      
      it 'should redirect to profile if incorrect activation code or empty' do
        test_sign_in(@user)
        get :activate, :activation_code => 123
        response.should redirect_to(users_path + "/#{@user.id}")
      end
    end

    describe 'when not signed in' do
      
      describe 'when activation code is empty or not valid' do
        it 'should redirect to signin path' do
         get :activate, :activation_code => 123
         response.should redirect_to(signin_path)  
        end
      end

      describe 'when the user is already activated' do

        it 'should render an already activated user message' do
          test_activate_user(@user)
          get :activate, :activation_code => @user.activation_code
          @user.reload
          @user.activated?.should be_true
          response.should redirect_to(signin_path)
          flash[:notice].should =~ /Your account has already been activated!/i
        end  
      end
      
      describe 'when the user not is activated' do
        
        it 'should activate the user and redirect to home pabe' do
          get :activate, :activation_code => @user.activation_code
          @user.reload
          @user.activated?.should be_true
          response.should redirect_to(root_path)
        end
      end
    end
  end
end