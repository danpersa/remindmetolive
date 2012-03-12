require 'spec_helper'

describe IdeasController do
  render_views

  describe 'access control' do

    describe 'authentication' do
      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          post :create
        end
      end
      
      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          delete :destroy, :id => 1
        end
      end
      
      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          get :show, :id => 1
        end
      end
    end
    
    describe 'own idea' do
      
      before(:each) do
        @user = Factory :unique_user
        wrong_user = Factory :unique_user, :email => Factory.next(:email)
        test_sign_in wrong_user
        @idea = Factory :idea, :created_by => @user, :owned_by => @user
      end
      
      it 'should deny access if user does not own the idea' do
        delete :destroy, :id => @idea
        response.should redirect_to(root_path)
      end
    end
  end
  
  describe 'GET show' do
 
    describe 'success' do

      before(:each) do
        @public_privacy = Privacy::Values[:public]
        @user = Factory(:user)
        @idea = Factory(:idea, :user => @user)
      end

      describe 'should allow access' do
        
        before(:each) do
          private_reminder = Factory(:reminder, :user => @user, :idea => @idea, :privacy => Privacy::Values[:private])
        end

        it 'to own private idea' do
          test_sign_in(@user)
          get :show, :id => @idea
          response.should be_successful
        end

        it 'to another user\'s public idea for which you have reminders' do
          public_reminder = Factory(:reminder, :user => @user, :idea => @idea, :privacy => @public_privacy)
          # now the idea is public
          another_user = Factory(:user, :email => Factory.next(:email))
          Factory(:reminder, :user => another_user, :idea => @idea, :privacy => @public_privacy)
          test_sign_in(another_user)
          get :show, :id => @idea
          response.should be_successful
        end  
      end
      
      it 'should show the idea' do
        Factory(:reminder, :user => @user, :idea => @idea, :privacy => @public_privacy)
        test_web_sign_in(@user)
        visit idea_path(@idea)
        page.should have_selector('div > h3', :text => @idea.content)
      end
      
      it 'should have a "create new reminder" link if the current user alredy shares the idea' do
        # we make the idea public
        Factory(:reminder, :user => @user, :idea => @idea, :privacy => @public_privacy)
        test_web_sign_in(@user)
        visit idea_path(@idea)
        page.should have_link('Create new reminder')
      end
      
      it 'should have a "users sharing this idea" link' do
        # we create a reminder for the idea
        Factory(:reminder, :user => @user, :idea => @idea, :privacy => @public_privacy)
        test_web_sign_in(@user)
        visit idea_path(@idea)
        page.should have_link('Users sharing this idea')
      end
      
      it 'should redirect to idea\'s users page if the logged user does not have any reminders' do
        test_sign_in(@user)
        get :show, :id => @idea
        response.should redirect_to users_idea_path(@idea)
      end
      
      it 'should have a create new reminder link' do
        Factory(:reminder, :user => @user, :idea => @idea, :privacy => @public_privacy)
        test_web_sign_in(@user)
        visit idea_path(@idea)
        page.should have_content('Create new reminder')
      end
      
      it 'should have an element for each of the user\'s reminder' do
        reminders = []
        private_privacy = Factory(:privacy, :name => 'private')
        2.times do
          reminders << Factory(:reminder, :user => @user, :idea => @idea, :privacy => @public_privacy)  
        end
        reminders << Factory(:reminder, :user => @user, :idea => @idea, :privacy => private_privacy)

        test_web_sign_in(@user)
        visit idea_path(@idea)
        reminders[0..2].each do |reminder|
          page.should have_selector('div', :text => reminder.reminder_date.to_s)
        end
      end
    end
    
    describe 'fail' do

      before(:each) do
        @private_privacy = Privacy::Values[:private]
        @user = Factory(:user)
        wrong_user = Factory(:user, :email => Factory.next(:email))
        test_sign_in(wrong_user)
        @idea = Factory(:idea, :user => @user)
        @private_reminder = Factory(:reminder, :user => @user, :idea => @idea, :privacy => @private_privacy)
      end

      it 'should deny access if the user is trying to access other user\'s private idea' do
        get :show, :id => @idea
        response.should redirect_to(root_path)
      end
      
      it 'should deny access if the user is trying to access an unexisting idea' do
        get :show, :id => 99999
        response.should redirect_to(root_path)
      end
      
    end
  end
  
  describe 'POST create' do

    before(:each) do
      @user = test_sign_in(Factory(:user))
    end

    describe 'success' do
        
      before(:each) do
        @privacy = Privacy::Values[:public]
        @attr = { :content => 'Lorem ipsum' }
        @reminder_attr = { :reminder_date => future_date, :privacy_id => @privacy }
      end
       
      it 'should create an idea' do
        lambda do
          post :create, :idea => @attr, :idea_reminder => @reminder_attr
        end.should change(Idea, :count).by(1)
      end
    
      it 'should redirect to the home page' do
        post :create, :idea => @attr, :idea_reminder => @reminder_attr
        response.should redirect_to(root_path)
      end
 
      it 'should have a flash message' do
        post :create, :idea => @attr, :idea_reminder => @reminder_attr
        flash[:success].should =~ /idea created/i
      end
    end

    describe 'failure' do

      before(:each) do
        @privacy = Privacy::Values[:public]
        @attr = { :content => ''}
        @reminder_attr = { :reminder_date => Time.now.next_year, :privacy_id => @privacy }
      end

      it 'should not create an idea without content' do
        lambda do
          post :create, :idea => @attr, :reminder => @reminder_attr
        end.should_not change(Idea, :count)
      end
      
      it 'should not create an idea without a reminder' do
        lambda do
          post :create, :idea => @attr.merge(:content => 'content')
        end.should_not change(Idea, :count)
      end

      it 'should render the home page' do
        post :create, :idea => @attr, :reminder => @reminder_attr
        response.should render_template('pages/home')
      end
    end
  end
  
  describe 'PUT update' do
    
    it 'should update tokens' do
      pending
    end
    
  end

  describe 'DELETE destroy' do

    describe 'success' do

      before(:each) do
        @privacy = Privacy::Values[:public]
        @user = test_sign_in(Factory(:user))
        @idea = Factory(:idea, :user => @user)
        @reminder = Factory(:reminder, :user => @user, :idea => @idea, :created_at => 1.day.ago, :privacy => @privacy)
        @idea_list = Factory(:idea_list, :user => @user)
        @idea_list_ownership = Factory(:idea_list_ownership, :idea => @idea, :idea_list => @idea_list)
      end
      
      describe 'the idea is shared with other users' do
        
        before(:each) do
          create_community_user
          other_user = Factory(:user, :email => Factory.next(:email))
          @other_reminder = Factory(:reminder, :user => other_user, :idea => @idea, :created_at => 1.day.ago, :privacy => @privacy)
          delete :destroy, :id => @idea
        end
        
        it 'should donate the idea to the community' do
          @idea.reload
          @idea.user.name.should == 'community'
        end
        
        it 'should destroy all the reminders of the user that wants to delete the idea' do
          Reminder.find_by_id(@reminder.id).should be_nil
        end
        
        it 'should destroy all the idea list ownerships of the idea from the user\'s lists' do
          IdeaListOwnership.find_by_id(@idea_list_ownership.id).should be_nil
        end
        
        it 'should not destroy the reminders of other users' do
          Reminder.find_by_id(@other_reminder.id).should_not be_nil
        end  
          
      end
      
      describe 'the idea is not shared with other users' do
        it 'should destroy the idea' do
          lambda do 
            delete :destroy, :id => @idea
          end.should change(Idea, :count).by(-1)
        end
        
        it 'should destroy all it\'s reminders' do
          Reminder.find_by_idea_id(@idea.id).should_not be_nil
          delete :destroy, :id => @idea
          Reminder.find_by_idea_id(@idea.id).should be_nil
        end
        
        it 'should destroy all the idea list ownerships of the idea from the user\'s lists' do
          IdeaListOwnership.find_by_idea_id(@idea.id).should_not be_nil
          delete :destroy, :id => @idea
          IdeaListOwnership.find_by_idea_id(@idea.id).should be_nil
        end
      end
    
    end

    describe 'failure' do

      it 'should deny access if the idea does not exist' do
        test_sign_in(Factory(:user))
        delete :destroy, :id => 9999
        response.should redirect_to(root_path)
      end
    end
  end
  
  describe 'GET users' do
    
    describe 'fail' do

      before(:each) do
        @private_privacy = Privacy::Values[:private]
        @user = Factory(:user)
        wrong_user = Factory(:user, :email => Factory.next(:email))
        test_sign_in(wrong_user)
        @idea = Factory(:idea, :user => @user)
        @private_reminder = Factory(:reminder, :user => @user, :idea => @idea, :privacy => @private_privacy)
      end

      it 'should deny access if the user is trying to access other user\'s private idea' do
        get :users, :id => @idea
        response.should redirect_to(root_path)
      end
      
      it 'should deny access if the user is trying to access an unexisting idea' do
        get :users, :id => 99999
        response.should redirect_to(root_path)
      end
      
    end
    
    describe 'success' do

      before(:each) do
        @public_privacy = Privacy::Values[:public]
        @user = Factory(:user)
        @idea = Factory(:idea, :user => @user)
      end

      describe 'should allow access' do
        
        before(:each) do
          private_privacy = Factory(:privacy, :name => 'private')
          private_reminder = Factory(:reminder, :user => @user, :idea => @idea, :privacy => private_privacy)
        end

        it 'to own private idea' do
          test_sign_in(@user)
          get :users, :id => @idea
          response.should be_successful
        end

        it 'to another user\'s public idea' do
          public_reminder = Factory(:reminder, :user => @user, :idea => @idea, :privacy => @public_privacy)
          # now the idea is public
          wrong_user = Factory(:user, :email => Factory.next(:email))
          test_sign_in(wrong_user)
          get :users, :id => @idea
          response.should be_successful
        end  
      end
      
      it 'should show the idea' do
        test_web_sign_in(@user)
        visit idea_path(@idea) + '/users'
        page.should have_selector('div > h3', :text => @idea.content)
      end
      
      it 'should have a "remind me too" link if the current user doesn\'t share the idea' do
        # we make the idea public
        Factory(:reminder, :user => @user, :idea => @idea, :privacy => @public_privacy)
        wrong_user = Factory(:user, :email => Factory.next(:email))
        test_web_sign_in(wrong_user)
        visit idea_path(@idea) + '/users'
        page.should have_link('Remind me too')
      end
      
      it 'should have a "create new reminder" link if the current user alredy shares the idea' do
        # we make the idea public
        Factory(:reminder, :user => @user, :idea => @idea, :privacy => @public_privacy)
        test_web_sign_in(@user)
        visit idea_path(@idea) + '/users'
        page.should have_link('Create new reminder')
      end
      
      it 'should have a "my reminders" if the current user already shares the idea' do
        # we make the idea public
        Factory(:reminder, :user => @user, :idea => @idea, :privacy => @public_privacy)
        test_web_sign_in(@user)
        visit idea_path(@idea) + '/users'
        page.should have_link('My reminders')
      end
      
      it 'should have an element for each user that shares the idea as public' do
        @users = []
        @users << @user
        2.times do
          another_user = Factory(:user, :email => Factory.next(:email))
          @users << another_user
          Factory(:reminder, :user => another_user, :idea => @idea, :privacy => @public_privacy)  
        end
        
        test_web_sign_in(@user)
        visit idea_path(@idea) + '/users'
        @users[0..2].each do |user|
          page.should have_selector('a', :text => user.name)
        end
      end
    end
  end
end
