shared_examples_for 'idea head' do
  context 'when success' do

    before(:each) do
      @public_privacy = Privacy::Values[:public]
      @user = FactoryGirl.create :user
      @idea = FactoryGirl.create :idea, :owned_by => @user
    end

    describe 'should allow access' do
      
      it 'to own private idea' do
        test_sign_in @user
        get requested_page, :id => @idea
        response.should be_successful
      end

      it 'to another user\'s public idea for which you have reminders' do
        another_user = FactoryGirl.create :unique_user
        test_sign_in another_user
        get requested_page, :id => @idea
        response.should be_successful
      end
    end
    
    it 'should show the idea' do
      test_web_sign_in @user
      request_action
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
          request_action
          page.should have_link('Modify reminder')
        end
      end

      context 'and does not have a reminder for the user idea' do
        it 'should have a "create reminder" link' do
          test_web_sign_in @user
          request_action
          page.should have_link('Create reminder')
        end
      end
    end

    context 'user does not have a user idea for this idea' do
      it 'should have a "remind me too" link' do
        test_web_sign_in @user
        request_action
        page.should have_link('Remind me too')
      end
    end
    
    it 'should have a "users sharing this idea" link' do
      # we create a reminder for the idea
      test_web_sign_in @user
      request_action
      page.should have_link('Users sharing this idea')
    end
  end

  context 'when fail' do

    before(:each) do
      @user = FactoryGirl.create :user
      wrong_user = FactoryGirl.create :unique_user
      test_sign_in wrong_user
      @idea = FactoryGirl.create :idea, :owned_by => @user,
                      :privacy => Privacy::Values[:private]
    end

    it 'should deny access if the user is trying to access other user\'s private idea' do
      get requested_page, :id => @idea
      response.should redirect_to(root_path)
    end
    
    it 'should deny access if the user is trying to access an unexisting idea' do
      get requested_page, :id => @user.id
      response.should redirect_to(root_path)
    end
    
  end
end  