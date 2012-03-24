require 'spec_helper'

describe UserIdeasController do
  render_views

  describe 'POST create' do

    before(:each) do
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
      
      it 'should not create an idea without a reminder' do
        lambda do
          post :create, :user_idea => @attr.merge(:content => 'content')
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

end
