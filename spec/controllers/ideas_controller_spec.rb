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

      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          get :users_marked_the_idea_good, :id => 1
        end
      end

      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          get :users_marked_the_idea_done, :id => 1
        end
      end
    end
  end

  describe 'idea head for each tab' do
    it_should_behave_like 'idea head' do
      let :requested_page do
        :show
      end

      let :request_action do
        visit idea_path @idea
      end
    end

    it_should_behave_like 'idea head' do
      let :requested_page do
        :users
      end

      let :request_action do
        visit users_idea_path @idea
      end
    end

    it_should_behave_like 'idea head' do
      let :requested_page do
        :followed_users
      end

      let :request_action do
        visit followed_users_idea_path @idea
      end
    end

    it_should_behave_like 'idea head' do
      let :requested_page do
        :users_marked_the_idea_good
      end

      let :request_action do
        visit users_marked_the_idea_good_idea_path @idea
      end
    end

    it_should_behave_like 'idea head' do
      let :requested_page do
        :users_marked_the_idea_done
      end

      let :request_action do
        visit users_marked_the_idea_done_idea_path @idea
      end
    end
  end
  
  describe 'GET show' do
    it 'should' do
      pending
    end
    
  end  

  describe 'GET users' do

    before(:each) do
      @user = FactoryGirl.create :unique_user
      @idea = FactoryGirl.create :idea
      @users = []
      number_of_users.times do
        user = FactoryGirl.create :unique_user
        public_user_idea = FactoryGirl.create :user_idea,
                                              :idea => @idea,
                                              :privacy =>  Privacy::Values[:public],
                                              :user => user
        @users << user
      end
    end

    context 'success' do
      before do
        test_web_sign_in(@user)
        visit users_idea_path(@idea)
      end

      context 'without pagination' do

        let(:number_of_users) { 3 }

        it 'should have an element for each user that shares the idea as public' do
          @users.each do |user|
            page.should have_selector('a', :text => user.display_name)
          end
        end
      end

      context 'with pagination' do

        let(:number_of_users) { RemindMeToLive::Application.config.items_per_page + 1}

        it 'should paginate users' do
          page.should have_selector('ul.pagination')
          page.should have_link('2')
        end
      end
    end

    context 'failure' do

      let(:number_of_users) { 3 }

      before do
        @user1 = FactoryGirl.create :unique_user
        @user2 = FactoryGirl.create :unique_user
        private_user_idea = FactoryGirl.create :user_idea,
                                   :idea => @idea, 
                                   :privacy =>  Privacy::Values[:private],
                                   :user => @user1
        test_web_sign_in(@user)
        visit users_idea_path(@idea)
      end

      it 'should not have an element for users that share the idea as private' do
        page.should_not have_selector('a', :text => @user1.display_name)
      end

      it 'should have an element for users that don\'t share the idea' do
        page.should_not have_selector('a', :text => @user2.display_name)
      end
    end
  end

  describe 'GET followed users' do

    before(:each) do
      @user = FactoryGirl.create :unique_user
      @idea = FactoryGirl.create :idea
      @followed_users = []
      number_of_users.times do
        followed_user = FactoryGirl.create :unique_user
        @user.follow! followed_user
        public_user_idea_of_followed_user = 
                            FactoryGirl.create :user_idea, 
                                               :idea => @idea, 
                                               :privacy =>  Privacy::Values[:public],
                                               :user => followed_user
        @followed_users << followed_user
      end
    end

    context 'success' do

      before do
        test_web_sign_in(@user)
        visit followed_users_idea_path(@idea)
      end

      context 'without pagination' do

        let(:number_of_users) { 3 }

        it 'should have an element for each user followed by the logged user that shares the idea as public' do
          test_web_sign_in(@user)
          visit followed_users_idea_path(@idea)
          @followed_users.each do |user|
            page.should have_selector('a', :text => user.display_name)
          end
        end
      end

      context 'with pagination' do

        let(:number_of_users) { RemindMeToLive::Application.config.items_per_page + 1}

        it 'should paginate users' do
          page.should have_selector('ul.pagination')
          page.should have_link('2')
        end
      end
    end

    context 'failure' do

      let(:number_of_users) { 3 }

      before do
        @followed_user3 = FactoryGirl.create :unique_user
        @other_user = FactoryGirl.create :unique_user
        @not_sharing_user = FactoryGirl.create :unique_user
        @user.follow! @followed_user3
        @user.reload
        @user.password = 'foobar'
        @private_user_idea_of_followed_user3 = FactoryGirl.create :user_idea,
                                                      :idea => @idea, 
                                                      :privacy =>  Privacy::Values[:private],
                                                      :user => @followed_user3
        @public_user_idea_of_other_user = FactoryGirl.create :user_idea, 
                                                 :idea => @idea, 
                                                 :privacy =>  Privacy::Values[:public],
                                                 :user => @other_user
        test_web_sign_in(@user)
        visit followed_users_idea_path(@idea)
      end

      it 'should not have an element for users followed by the logged user that share the idea as private' do
        page.should_not have_selector('a', :text => @followed_user3.display_name)
      end

      it 'should not have an element for users not followed by the logged user that share the idea as public' do
        page.should_not have_selector('a', :text => @other_user.display_name)
      end

      it 'should have an element for users that don\'t share the idea' do
        page.should_not have_selector('a', :text => @not_sharing_user.display_name)
      end
    end
  end

  describe 'GET users marked the idea good' do

    before do
      @user = FactoryGirl.create :unique_user
      @idea = FactoryGirl.create :idea
      @users = []
      number_of_users.times do
        user = FactoryGirl.create :unique_user
        @users << user
        @idea.mark_as_good_by! user
      end
    end

    context 'success' do

      before do
        test_web_sign_in(@user)
        visit users_marked_the_idea_good_idea_path @idea
      end

      context 'without pagination' do
        let(:number_of_users) { 3 }

        it 'should have an element for each user that marked the idea as good' do
          @users.each do |user|
            page.should have_selector('a', :text => user.display_name)
          end 
        end
      end

      context 'with pagination' do

        let(:number_of_users) { RemindMeToLive::Application.config.items_per_page + 1}

        it 'should paginate users' do
          page.should have_selector('ul.pagination')
          page.should have_link('2')
        end
      end
    end

    context 'failure' do

      let(:number_of_users) { 3 }

      before do
        @user1 = FactoryGirl.create :unique_user
        test_web_sign_in(@user)
        visit users_marked_the_idea_good_idea_path @idea
      end

      it 'should not have an element for users that didn\'t mark the idea as good' do
        page.should_not have_selector('a', :text => @user1.display_name)  
      end
    end
  end

  describe 'GET users marked the idea done' do

    before do
      @user = FactoryGirl.create :unique_user
      @idea = FactoryGirl.create :idea
      @users = []
      number_of_users.times do
        user = FactoryGirl.create :unique_user
        @users << user
        @idea.mark_as_done_by! user
      end
    end

    context 'success' do

      before do
        test_web_sign_in(@user)
        visit users_marked_the_idea_done_idea_path @idea
      end

      context 'without pagination' do
        let(:number_of_users) { 3 }

        it 'should have an element for each user that marked the idea as done' do
          @users.each do |user|
            page.should have_selector('a', :text => user.display_name)
          end 
        end
      end

      context 'with pagination' do

        let(:number_of_users) { RemindMeToLive::Application.config.items_per_page + 1}

        it 'should paginate users' do
          page.should have_selector('ul.pagination')
          page.should have_link('2')
        end
      end
    end

    context 'failure' do

      let(:number_of_users) { 3 }

      before do
        @user1 = FactoryGirl.create :unique_user
        test_web_sign_in(@user)
        visit users_marked_the_idea_done_idea_path @idea
      end

      it 'should not have an element for users that didn\'t mark the idea as done' do
        page.should_not have_selector('a', :text => @user1.display_name)  
      end
    end
  end
end
