require 'spec_helper'

describe IdeasController do
  render_views

  describe 'access control' do
    describe 'authentication' do
      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          get :show, :id => 1
        end
      end

      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          get :users, :id => 1
        end
      end

      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          get :followed_users, :id => 1
        end
      end
    end
  end
  
  describe 'GET show' do

    it_should_behave_like 'idea head' do
      let :requested_page do
        :show
      end

      let :request_action do
        visit idea_path @idea
      end
    end
  end  

  describe 'GET users' do
    
    it_should_behave_like 'idea head' do
      let :requested_page do
        :users
      end

      let :request_action do
        visit users_idea_path @idea
      end
    end
    
    describe 'success' do

      before(:each) do
        @user = FactoryGirl.create :unique_user
        @user1 = FactoryGirl.create :unique_user
        @user2 = FactoryGirl.create :unique_user
        @idea = FactoryGirl.create :idea
        public_user_idea1 = FactoryGirl.create :user_idea, 
                                     :idea => @idea, 
                                     :privacy =>  Privacy::Values[:public],
                                     :user => @user1
        public_user_idea2 = FactoryGirl.create :user_idea, 
                                     :idea => @idea, 
                                     :privacy =>  Privacy::Values[:public], 
                                     :user => @user2
        private_user_idea = FactoryGirl.create :user_idea, 
                                     :idea => @idea, 
                                     :privacy =>  Privacy::Values[:private]
      end

      it 'should have an element for each user that shares the idea as public' do
        test_web_sign_in(@user)
        visit users_idea_path(@idea)
        #save_and_open_page
        [@user1, @user2].each do |user|
          page.should have_selector('a', :text => user.display_name)
        end
      end
    end
  end

  describe 'GET followed users' do
    
    it_should_behave_like 'idea head' do
      let :requested_page do
        :followed_users
      end

      let :request_action do
        visit followed_users_idea_path @idea
      end
    end


    describe 'success' do

      before(:each) do
        @user = FactoryGirl.create :unique_user
        @user1 = FactoryGirl.create :unique_user
        @user2 = FactoryGirl.create :unique_user
        @idea = FactoryGirl.create :idea
        public_user_idea1 = FactoryGirl.create :user_idea, 
                                     :idea => @idea, 
                                     :privacy =>  Privacy::Values[:public],
                                     :user => @user1
        public_user_idea2 = FactoryGirl.create :user_idea, 
                                     :idea => @idea, 
                                     :privacy =>  Privacy::Values[:public], 
                                     :user => @user2
        private_user_idea = FactoryGirl.create :user_idea, 
                                     :idea => @idea, 
                                     :privacy =>  Privacy::Values[:private]
      end

      it 'should have an element for each user that shares the idea as public' do
        test_web_sign_in(@user)
        visit users_idea_path(@idea)
        [@user1, @user2].each do |user|
          page.should have_selector('a', :text => user.display_name)
        end
      end
    end

    describe 'success' do

      before(:each) do
        @user = FactoryGirl.create :unique_user
        @followed_user1 = FactoryGirl.create :unique_user
        @followed_user2 = FactoryGirl.create :unique_user
        followed_user3 = FactoryGirl.create :unique_user
        other_user = FactoryGirl.create :unique_user
        @user.follow! @followed_user1
        @user.follow! @followed_user2
        @user.follow! followed_user3
        @user = User.find @user.id
        @user.password = 'foobar'
        @idea = FactoryGirl.create :idea
        public_user_idea_of_followed_user1 = FactoryGirl.create :user_idea, 
                                                     :idea => @idea, 
                                                     :privacy =>  Privacy::Values[:public],
                                                     :user => @followed_user1
        public_user_idea_of_followed_user2 = FactoryGirl.create :user_idea, 
                                                     :idea => @idea, 
                                                     :privacy =>  Privacy::Values[:public],
                                                     :user => @followed_user2
        private_user_idea_of_followed_user3 = FactoryGirl.create :user_idea,
                                                      :idea => @idea, 
                                                      :privacy =>  Privacy::Values[:private],
                                                      :user => followed_user3
        public_user_idea_of_other_user = FactoryGirl.create :user_idea, 
                                                 :idea => @idea, 
                                                 :privacy =>  Privacy::Values[:public],
                                                 :user => other_user
      end

      it 'should have an element for each user followed by the logged user that shares the idea as public' do
        test_web_sign_in(@user)
        visit followed_users_idea_path(@idea)
        [@followed_user1, @followed_user2].each do |user|
          page.should have_selector('a', :text => user.display_name)
        end
      end
    end
  end
end
