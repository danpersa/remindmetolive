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
        @user = Factory :user
        @idea = Factory :idea, :owned_by => @user
      end

      describe 'should allow access' do
        
        it 'to own private idea' do
          test_sign_in @user
          get :show, :id => @idea
          response.should be_successful
        end

        it 'to another user\'s public idea for which you have reminders' do
          another_user = Factory :unique_user
          test_sign_in another_user
          get :show, :id => @idea
          response.should be_successful
        end
      end
      
      it 'should show the idea' do
        test_web_sign_in @user
        visit idea_path @idea
        page.should have_selector('div > h3', :text => @idea.content)
      end

      context 'user has an user idea for this idea' do
        before do
          @user_idea = @user.create_user_idea! :privacy => @public_privacy,
                                               :idea_id => @idea.id
        end

        context 'and has a reminder for the user idea' do

          it 'should have a "modify reminder" link' do
            @user_idea.reminder_date = Date.new(2014)
            @user_idea.save!
            test_web_sign_in @user
            visit idea_path @idea
            page.should have_link('Modify reminder')
          end
        end

        context 'and does not have a reminder for the user idea' do
          it 'should have a "create reminder" link' do
            test_web_sign_in @user
            visit idea_path @idea
            page.should have_link('Create reminder')
          end
        end
      end

      context 'user does not have a user idea for this idea' do
        it 'should have a "remind me too" link' do
          test_web_sign_in @user
          visit idea_path @idea
          page.should have_link('Remind me too')
        end
      end
      
      it 'should have a "users sharing this idea" link' do
        # we create a reminder for the idea
        test_web_sign_in @user
        visit idea_path @idea
        page.should have_link('Users sharing this idea')
      end
    end
    
    describe 'fail' do

      before(:each) do
        @user = Factory :user
        wrong_user = Factory :unique_user
        test_sign_in wrong_user
        @idea = Factory :idea, :owned_by => @user,
                        :privacy => Privacy::Values[:private]
      end

      it 'should deny access if the user is trying to access other user\'s private idea' do
        get :show, :id => @idea
        response.should redirect_to(root_path)
      end
      
      it 'should deny access if the user is trying to access an unexisting idea' do
        get :show, :id => @user.id
        response.should redirect_to(root_path)
      end
      
    end
  end  

  describe 'GET users' do
    
    describe 'fail' do

      before(:each) do
        @private_privacy = Privacy::Values[:private]
        @user = Factory :user
        wrong_user = Factory :unique_user
        test_sign_in wrong_user
        @idea = Factory :idea, :owned_by => @user,
                        :privacy => Privacy::Values[:private]
      end

      it 'should deny access if the user is trying to access other user\'s private idea' do
        get :users, :id => @idea
        response.should redirect_to(root_path)
      end
      
      it 'should deny access if the user is trying to access an unexisting idea' do
        get :users, :id => @user.id
        response.should redirect_to(root_path)
      end

    end
    
    describe 'success' do

      before(:each) do
        @public_privacy = Privacy::Values[:public]
        @user = Factory :user
        @idea = Factory :idea, :owned_by => @user
      end

      describe 'should allow access' do
        
        before(:each) do
          private_privacy = Privacy::Values[:private]
          private_reminder = Factory :reminder, :user => @user,
                                     :idea => @idea,
                                     :privacy => private_privacy
        end

        it 'to own private idea' do
          test_sign_in @user
          get :users, :id => @idea
          response.should be_successful
        end

        it 'to another user\'s public idea' do
          wrong_user = Factory :user, :email => Factory.next(:email)
          test_sign_in wrong_user
          get :users, :id => @idea
          response.should be_successful
        end  
      end

      it 'should show the idea' do
        test_web_sign_in @user
        visit users_idea_path(@idea)
        page.should have_selector('div > h3', :text => @idea.content)
      end

      it 'should have a "remind me too" link if the current user doesn\'t share the idea' do
        wrong_user = Factory :user, :email => Factory.next(:email)
        test_web_sign_in wrong_user
        visit users_idea_path(@idea)
        page.should have_link('Remind me too')
      end

      it 'should have a "create new reminder" link if the current user alredy shares the idea' do
        test_web_sign_in @user
        visit users_idea_path(@idea)
        page.should have_link('Create new reminder')
      end

      it 'should have a "my reminders" if the current user already shares the idea' do
        test_web_sign_in @user
        visit idea_path(@idea) + '/users'
        page.should have_link('My reminders')
      end

      it 'should have an element for each user that shares the idea as public' do
        @users = []
        @users << @user
        2.times do
          another_user = Factory :user, :email => Factory.next(:email)
          @users << another_user
          Factory :reminder, :user => another_user, :idea => @idea, :privacy => @public_privacy
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
