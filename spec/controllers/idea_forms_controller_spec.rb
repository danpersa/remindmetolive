require 'spec_helper'

describe IdeaFormsController do
  render_views

  before(:each) do
    @base_title = 'Remind me to live'
  end

  describe 'access control' do
    describe 'authentication' do

      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          get :show, :id => 1
        end
      end

      it_should_behave_like 'deny access unless signed in' do
        let(:request_action) do
          post :create
        end
      end
    end

    describe '#own_idea_or_public_if_exists' do
      it 'should allow access if the idea is not existing' do
        pending
      end

      it 'should allow access if the user owns the idea' do
        pending
      end

      it 'should allow access if the idea is public' do
        pending
      end

      it 'should deny access if the idea is private and the user does not own it' do
        pending
      end

    end
  end

  describe 'POST create' do
    before do
      @user = test_sign_in(FactoryGirl.create(:unique_user))
    end

    context 'when success' do

      let :attr do
        {
          content: 'idea content',
          privacy: Privacy::Values[:public],
          repeat: Repeat::Values[:never],
          reminder_on: '3/20/2015'
        }
      end
       
      it 'should create an idea' do
        lambda do
          post :create, idea_form: attr  
        end.should change(Idea, :count).by(1)
      end

      it 'should create an user idea' do
        lambda do
          post :create, :idea_form => attr  
        end.should change(UserIdea, :count).by(1)
      end
    
      it 'should redirect to the home page' do
        post :create, :idea_form => attr
        response.should redirect_to(root_path)
      end

      it 'should have a flash message' do
        post :create, :idea_form => attr
        flash[:success].should =~ /idea created/i
      end
    end

    context 'when failure' do

      let :attr do
        {
          privacy: Privacy::Values[:public],
          repeat: Repeat::Values[:never],
          reminder_on: '3/20/2015'
        }
      end

      it 'should not create an idea without content' do
        lambda do
          post :create, :idea_form => attr
        end.should_not change(Idea, :count)
      end

      it 'should render the home page' do
        post :create, :idea_form => attr
        response.should render_template('pages/home')
      end
    end
  end
end