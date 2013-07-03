require 'spec_helper'

describe IdeaForm do

  before do
    @user = FactoryGirl.create(:simple_user)
    @idea_form = IdeaForm.new @user
  end

  context 'when validation fails' do
    context 'when content is missing' do
      context 'when idea_id is missing' do
        let :params do
          {
            privacy: Privacy::Values[:public],
            repeat: Repeat::Values[:never],
            reminder_on: '3/20/2015'
          }
        end

        before do
          @result = @idea_form.submit(params)
        end

        it 'should not submit the form' do
          @result.should == false
        end

        it 'should have validation errors' do
          @idea_form.errors.size.should == 2
        end

        it 'should have a not blank error' do
          @idea_form.errors[:content][0].should == 'can\'t be blank'
        end

        it 'should have a to short error' do
          @idea_form.errors[:content][1].should == 'is too short (minimum is 3 characters)'
        end
      end

      context 'when idea_id is present' do

        before do
          idea = FactoryGirl.create(:simple_idea, created_by: @user, owned_by: @user)
          params = {
            privacy: Privacy::Values[:public],
            repeat: Repeat::Values[:never],
            reminder_on: '3/20/2015',
            idea_id: idea.id
          }
          @result = @idea_form.submit(params)
        end

        it 'should be valid' do
          @result.should == true
        end
      end
    end

    context 'when idea id is present' do
      context 'when the idea does not exist' do

        it 'should not submit the form' do
          pending
        end

      end
    end

    context 'when the repeat is not present' do
      let :params do
        {
          content: 'idea content 5',
          privacy: Privacy::Values[:public],
          reminder_on: '3/20/2015'
        }
      end

      before do
        @result = @idea_form.submit(params)
      end

      it 'should not submit the form' do
        @result.should == false
      end

      it 'should have validation errors' do
        @idea_form.errors.size.should == 2
      end

      it 'should have a not blank error' do
        @idea_form.errors[:repeat][0].should == 'can\'t be blank'
      end

      it 'should have a to short error' do
        @idea_form.errors[:repeat][1].should == 'is not included in the list'
      end
    end

    context 'when repeat and reminder on does not match' do
      it 'should not submit the form' do
        pending
      end
    end

    context 'when privacy is not present' do
      it 'should not submit the form' do
        pending
      end
    end

    context 'when the reminder date is in the past' do
      let :params do
        {
          content: 'idea content 4',
          privacy: Privacy::Values[:public],
          repeat: Repeat::Values[:never],
          reminder_on: '3/20/2012'
        }
      end

      before do
        @result = @idea_form.submit(params)
      end

      it 'should not submit the form' do
        @result.should == false
      end

      it 'should have validation errors' do
        @idea_form.errors.size.should == 1
      end

      it 'should have a cannot be in the past error' do
        @idea_form.errors[:reminder_on].should == ['can\'t be in the past']
      end
    end
  end
  
  context 'when the idea does not exist' do
    context 'when the reminder date is specified' do

      let :params do
        {
          content: 'idea content',
          privacy: Privacy::Values[:public],
          repeat: Repeat::Values[:never],
          reminder_on: '3/20/2015'
        }
      end

      before do
        @idea_form.submit(params)
        @result_user = User.find_by_email @user.email
      end

      it 'should create a new user idea for the user' do
        @result_user.ideas.size.should == 1
        @result_user.ideas.first.repeat.should == Repeat::Values[:never]
      end

      it 'should create a new idea for the user' do
        @result_user.ideas.first.idea.content.should == params[:content]
        @result_user.ideas.first.idea.owned_by.should == @user
      end
    end

    context 'when the reminder date is not specified' do
      let :params do
        {
          content: 'idea content 1',
          privacy: Privacy::Values[:public],
          repeat: Repeat::Values[:never]
        }
      end

      before do
        @idea_form.submit(params)
        @result_user = User.find_by_email @user.email
      end

      it 'should create a user idea for the user' do
         @result_user.ideas.size.should == 1
      end

      it 'should create a new idea' do
        Idea.count.should == 1
        idea = Idea.first
        idea.content.should == params[:content]
        idea.owned_by.should == @user
      end
    end
  end

  context 'when the idea already exists' do

    before do
      @idea = FactoryGirl.create(:simple_idea, created_by: @user, owned_by: @user)
    end

    context 'when the user idea for the user already exists' do
      before do
        @user_idea = FactoryGirl.create(:simple_user_idea, user: @user, idea: @idea)
      end

      context 'when the reminder date is not specified' do

        before do
          params = {
            idea_id: @idea.id,
            privacy: Privacy::Values[:public],
            repeat: Repeat::Values[:never]
          }

          @idea_form.submit(params)
          @result_user = User.find_by_email @user.email
          @result_user_idea = UserIdea.find_by_id @user_idea.id
        end

        it 'should not destroy the existing user idea' do
          @result_user_idea.should_not be_nil
        end

        it 'should change the next reminder date to nil' do
          @result_user_idea.reminder_date.should be_nil
        end
      end

      context 'when the reminder date is specified' do
        before do
          params = {
            idea_id: @idea.id,
            privacy: Privacy::Values[:public],
            repeat: Repeat::Values[:never],
            reminder_on: '3/20/2015'
          }

          @idea_form.submit(params)
          @result_user = User.find_by_email @user.email
          @result_user_idea = UserIdea.find_by_id @user_idea.id
        end

        it 'should not destroy the existing user idea' do
          @result_user_idea.should_not be_nil
        end

        it 'should change the next reminder date to the specified date' do
          @result_user_idea.reminder_date.should == DateTime.new(2015, 3, 20).to_date
        end

        it 'should not create a new idea' do
          Idea.count.should == 1
        end
      end
    end

    context 'when the user idea for the user does not exist' do
      context 'when the reminder date is not specified' do
        before do
          params = {
            idea_id: @idea.id,
            privacy: Privacy::Values[:public],
            repeat: Repeat::Values[:never]
          }
          @idea_form.submit(params)
          @result_user = User.find_by_email @user.email
          @result_user_idea = @result_user.ideas.first
        end

        it 'should create a user idea without a date' do
          @result_user_idea.should_not be_nil
        end
      end

      context 'when the reminder date is specified' do
        before do
          params = {
            idea_id: @idea.id,
            privacy: Privacy::Values[:public],
            repeat: Repeat::Values[:never],
            reminder_on: '3/20/2015'
          }
          @idea_form.submit(params)
          @result_user = User.find_by_email @user.email
          @result_user_idea = @result_user.ideas.first
        end

        it 'should create a new user idea with the specified date' do
          @result_user_idea.reminder_date.should == DateTime.new(2015, 3, 20).to_date
        end
      end
    end
  end
end
