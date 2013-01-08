require 'spec_helper'

describe UserIdeasController do
  render_views

  describe 'access control' do

    describe 'authentication' do
      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          post :index
        end
      end

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
    end
    
    describe '#shared_by_logged_user' do
      
      before(:each) do
        @user = test_sign_in FactoryGirl.create :unique_user
        other_user = FactoryGirl.create :unique_user
        @idea = FactoryGirl.create :simple_idea, :created_by => @user,
                                      :owned_by => @user,
                                      :privacy => Privacy::Values[:public]
        @user_idea = FactoryGirl.create :user_idea, :idea => @idea,
                                         :user => other_user
        @own_user_idea = FactoryGirl.create :user_idea, :idea => @idea,
                                             :user => @user
      end
      
      it 'should deny access if user does not own the user idea' do
        delete :destroy, :id => @user_idea.id
        response.should redirect_to(root_path)
        flash[:success].should_not == 'Successfully deleted shared idea!'
      end

      it 'should not deny access if user does own the user idea' do
        delete :destroy, :id => @own_user_idea.id
        flash[:success].should == 'Successfully deleted shared idea!'
      end
    end
  end

  describe 'GET index' do
    before do
      user = FactoryGirl.create :unique_user
      @user_ideas = []
      number_of_ideas.times do |index|
        idea = FactoryGirl.create :idea, :content => 'Baz quux ' + index.to_s,
                                         :created_by => user,
                                         :owned_by => user,
                                         :privacy => Privacy::Values[:public]
        user_idea = user.create_user_idea! :idea_id => idea.id,
                                           :privacy => Privacy::Values[:public]
        @user_ideas << user_idea
      end
      test_web_sign_in(user)
      visit user_ideas_path
    end

    context "withou pagination" do
      let :number_of_ideas do
        RemindMeToLive::Application.config.items_per_page - 1
      end

      it 'should show the public user ideas entries' do
        index = 0
        @user_ideas.each do |user_idea|
          page.should have_selector('strong', :text => user_idea.idea.content) if
                index < RemindMeToLive::Application.config.items_per_page
          index += 1
        end
      end
    end
    
    context 'with pagination' do
      let :number_of_ideas do
        RemindMeToLive::Application.config.items_per_page + 1
      end

      it 'should paginate the ideas' do
        page.should have_selector('ul.pagination')
        page.should have_link('2')
      end
    end
  end

  describe 'POST create' do

    before do
      @user = test_sign_in(FactoryGirl.create(:unique_user))
    end

    context 'when success' do

      let :attr do
        { :idea => { :content => 'Lorem ipsum' },
          :privacy => Privacy::Values[:public],
          :reminder_date => Date.new(2014) }
      end
       
      it 'should create an idea' do
        lambda do
          post :create, :user_idea => attr  
        end.should change(Idea, :count).by(1)
      end

      it 'should create an user idea' do
        lambda do
          post :create, :user_idea => attr  
        end.should change(UserIdea, :count).by(1)
      end
    
      it 'should redirect to the home page' do
        post :create, :user_idea => attr
        response.should redirect_to(root_path)
      end

      it 'should have a flash message' do
        post :create, :user_idea => attr
        flash[:success].should =~ /idea created/i
      end
    end

    context 'when failure' do

      let :attr do
        { :idea => { :content => '' },
          :privacy => Privacy::Values[:public],
          :reminder_date => Date.new(2014) }
      end

      it 'should not create an idea without content' do
        lambda do
          post :create, :user_idea => attr
        end.should_not change(Idea, :count)
      end

      it 'should render the home page' do
        post :create, :user_idea => attr
        response.should render_template('pages/home')
      end
    end
  end

  describe 'DELETE destroy' do
    before do
      @user = test_sign_in FactoryGirl.create(:unique_user)
    end

    describe 'success' do

      context 'the idea corresponding to the user idea is owned by the user' do
        context 'when the idea is private' do

          before do
            idea = FactoryGirl.create :simple_idea, :created_by => @user,
                                   :owned_by => @user,
                                   :privacy => Privacy::Values[:private]
            @user_idea = FactoryGirl.create :user_idea, :idea => idea, :user => @user
          end

          it 'should destroy the idea' do
            lambda do 
              delete :destroy, :id => @user_idea.id
            end.should change(Idea, :count).by(-1)
          end

          it 'should destroy the user idea' do
            lambda do 
              delete :destroy, :id => @user_idea.id
            end.should change(UserIdea, :count).by(-1)
          end
        end

        context 'when the idea is public' do
          before do
            @idea = FactoryGirl.create :simple_idea, :created_by => @user,
                                          :owned_by => @user,
                                          :privacy => Privacy::Values[:public]
            @user_idea = FactoryGirl.create :user_idea, :idea => @idea,
                                             :user => @user
          end

          context 'when the idea is shared with other users' do
            before do
              other_user = FactoryGirl.create :unique_user
              other_user_idea = FactoryGirl.create :user_idea, :idea => @idea,
                                                    :user => other_user
            end

            it 'should not destroy idea' do
              lambda do 
                delete :destroy, :id => @user_idea.id
              end.should_not change(Idea, :count).by(-1)
            end

            it 'should destroy the user idea' do
              lambda do 
                delete :destroy, :id => @user_idea.id
              end.should change(UserIdea, :count).by(-1)
            end
          end

          context 'when the idea is not shared with other users' do
            it 'should not destroy the idea' do
              lambda do 
                delete :destroy, :id => @user_idea.id
              end.should_not change(Idea, :count).by(-1)
            end

            it 'should destroy the user idea' do
              lambda do 
                delete :destroy, :id => @user_idea.id
              end.should change(UserIdea, :count).by(-1)
            end
          end
        end
      end

      context 'when the idea corresponding to the user idea is owned by some other user' do

        before do
          other_user = FactoryGirl.create :unique_user
          @idea = FactoryGirl.create :idea, :created_by => other_user,
                                 :owned_by => other_user,
                                 :privacy => Privacy::Values[:public]
          @user_idea = FactoryGirl.create :user_idea, :idea => @idea,
                                           :user => @user          
        end

        it 'should not destroy idea' do
          lambda do 
            delete :destroy, :id => @user_idea.id
          end.should_not change(Idea, :count).by(-1)
        end

        it 'should destroy the user idea' do
          lambda do 
            delete :destroy, :id => @user_idea.id
          end.should change(UserIdea, :count).by(-1)
        end
      end
    end

    describe 'failure' do

      it 'should deny access if the user idea does not exist' do
        test_sign_in FactoryGirl.create(:unique_user)
        delete :destroy, :id => @user.id
        response.should redirect_to(root_path)
      end

      it 'should deny access if the user does not own the user idea' do
        test_sign_in FactoryGirl.create(:unique_user)
        delete :destroy, :id => @user.id
        response.should redirect_to(root_path)
      end
    end
  end

end
