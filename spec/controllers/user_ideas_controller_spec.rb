require 'spec_helper'

describe UserIdeasController do
  render_views

  describe 'POST create' do

    before do
      @user = test_sign_in(Factory(:user))
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
  
  describe 'PUT update' do

    it 'should update tokens' do
      pending
    end

  end

  describe 'DELETE destroy' do

    describe 'success' do

      before do
        @user = test_sign_in Factory(:unique_user)
      end

      context 'the idea corresponding to the user idea is owned by the user' do
        context 'when the idea is private' do

          before do
            @idea = Factory :idea, :created_by => @user,
                                   :owned_by => @user,
                                   :privacy => Privacy::Values[:private]
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
        
        context 'when the idea is public and shared with other users' do
          before do
            @idea = Factory :idea, :created_by => @user,
                                   :owned_by => @user,
                                   :privacy => Privacy::Values[:public]
            other_user = Factory :unique_user
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

        context 'when the idea is public not shared with other users' do
          before do
            @idea = Factory :idea, :created_by => @user,
                                   :owned_by => @user,
                                   :privacy => Privacy::Values[:public]
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
      end

      context 'when the idea corresponding to the user idea is owned by some other user' do

        before do
          other_user = Factory :unique_user
          @idea = Factory :idea, :created_by => other_user,
                                 :owned_by => other_user,
                                 :privacy => Privacy::Values[:public]
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
        test_sign_in Factory(:user)
        delete :destroy, :id => @user.id
        response.should redirect_to(root_path)
      end

      it 'should deny access if the user does not own the user idea' do
        pending
      end
    end
  end

end
