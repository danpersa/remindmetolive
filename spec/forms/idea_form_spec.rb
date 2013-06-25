require 'spec_helper'

describe IdeaForm do

  let(:user) do
    FactoryGirl.create(:simple_user)
  end

  let(:idea_form) do
    IdeaForm.new user
  end

  context 'when validation fails' do
    context 'when content is missing' do
      let(:params) do
        {
          privacy: Privacy::Values[:public],
          repeat: Repeat::Values[:never],
          reminder_on: '3/20/2015'
        }
      end

      before do
        @result = idea_form.submit(params)
      end

      it 'should not submit the form' do
        @result.should == false
      end

      it 'should have validation errors' do
        idea_form.errors.size.should == 2
      end

      it 'should have a not blank error' do
        idea_form.errors[:content][0].should == 'can\'t be blank'
      end

      it 'should have a to short error' do
        idea_form.errors[:content][1].should == 'is too short (minimum is 3 characters)'
      end
    end
  end
  
  context 'when the idea does not exist' do
    context 'when the reminder date is specified' do

      let(:params) do
        {
          content: 'idea content',
          privacy: Privacy::Values[:public],
          repeat: Repeat::Values[:never],
          reminder_on: '3/20/2015'
        }
      end

      before do
        idea_form.submit(params)
        @result_user = User.find_by_email user.email
      end

      it 'should create a new user idea for the user' do
        @result_user.ideas.size.should == 1
        @result_user.ideas.first.repeat.should == Repeat::Values[:never]
      end

      it 'should create a new idea for the user' do
        @result_user.ideas.first.idea.content.should == params[:content]
        @result_user.ideas.first.idea.owned_by.should == user
      end
    end

    context 'when the reminder date is not specified' do
      let(:params) do
        {
          content: 'idea content 1',
          privacy: Privacy::Values[:public],
          repeat: Repeat::Values[:never]
        }
      end

      before do
        idea_form.submit(params)
        @result_user = User.find_by_email user.email
      end

      it 'should not create a user idea for the user' do
         @result_user.ideas.size.should == 0
      end

      it 'should create a new idea' do
        Idea.count.should == 1
        idea = Idea.first
        idea.content.should == params[:content]
        idea.owned_by.should == user
      end
    end
  end

  context 'when the idea already exists' do
    context 'when the user idea for the user already exists' do
      context 'when the reminder date is not specified' do
        it 'should destroy the existing user idea' do
          pending
        end
      end

      context 'when the reminder date is specified' do
        it 'should update the existing idea' do
          pending
        end
      end
    end

    context 'when the user idea for the user does not exist' do
      context 'when the reminder date is not specified' do
        it 'should not create a user idea' do
          pending
        end
      end

      context 'when the reminder date is specified' do
        it 'should create a new user idea for the user' do
          pending
        end
      end
    end
  end
end
