require 'spec_helper'

describe IdeaList do

  let :user do
    FactoryGirl.build :pending_user
  end

  before do
    @attr = { :name => "The Bucket List" }
  end

  describe 'creation' do
    it 'should create a new instance given valid attributes' do
      user.idea_lists.create!(@attr)
    end
  end

  describe 'field validation' do
    describe 'name field' do

      describe 'when validating presence' do
        it 'should require nonblank name' do
          idea_list = user.idea_lists.build(@attr.merge(:name => '  '))
          idea_list.should_not be_valid
          idea_list.errors[:name].include?("can't be blank").should == true
        end
      end

      describe 'when validating length' do
        context 'too short' do
          it 'should reject short content' do
            idea_list = user.idea_lists.build(@attr.merge(:name => 'a'))
            idea_list.should_not be_valid
            idea_list.errors[:name].should == ['is too short (minimum is 3 characters)']
          end
        end

        context 'too long' do
          it 'should reject long content' do
            idea_list = user.idea_lists.build(@attr.merge(:name => 'a' * 31))
            idea_list.should_not be_valid
            idea_list.errors[:name].should == ['is too long (maximum is 30 characters)']
          end
        end
      end

      describe 'unique name per user' do
        it 'should require an unique name per user' do
          user.idea_lists.create!(@attr)
          user.idea_lists.build(@attr).should_not be_valid
        end

        it 'should allow other user to use the same name' do
          user.idea_lists.create!(@attr)
          other_user = FactoryGirl.create(:user, :email => FactoryGirl.generate(:email))
          other_user.idea_lists.build(@attr).should be_valid
        end
      end
    end

    describe 'ideas_count field' do
      it 'should exist' do
        idea_list = user.idea_lists.build(@attr)
        idea_list.should respond_to :ideas_count
      end
    end
  end

  describe 'ideas association' do
    let :idea_list do
      user.idea_lists.create(@attr)
    end

    before do
      @idea1 = FactoryGirl.create(:idea, :created_by => idea_list.user, :owned_by => idea_list.user)
      @idea2 = FactoryGirl.create(:idea, :created_by => idea_list.user, :owned_by => idea_list.user)
      idea_list.ideas.push @idea1
      idea_list.ideas.push @idea2
    end

    it 'should have an ideas attribute' do
      idea_list.should respond_to(:ideas)
    end

    it 'should have the right ideas' do
      idea_list.ideas.should == [@idea1, @idea2]
    end

    it 'should not destroy associated ideas' do
      idea_list.destroy
      [@idea1, @idea2].each do |idea|
        Idea.find(idea.id).should_not be_nil
      end
    end
  end

  describe 'user embedded associated' do
    describe 'when validating presence' do
      it 'should require the user field' do
        idea_list = IdeaList.new(@attr)
        idea_list.should_not be_valid
        idea_list.errors[:user].should == ['must be present']
      end
    end
  end

  describe 'methods' do
    describe 'add idea as' do
      before do
        @user = FactoryGirl.create(:unique_user)
        @idea_list = @user.idea_lists.create(@attr)
      end

      describe 'the user already has the idea in his user ideas' do
        before do
          @user.create_new_idea!(:content => 'ana are mere', :privacy => Privacy::Values[:public])
          idea = Idea.first
          @idea_list.add_idea_as idea
        end

        it 'should add the idea to the idea list' do
          @user.idea_lists.first.ideas.first.idea.content.should == 'ana are mere'
        end

        it 'should increment the ideas_count' do
          @user.idea_lists.first.ideas_count.should == 1
        end
      end

      describe 'the user doesn\'t have the idea in his user ideas' do

        before do
          @another_user = FactoryGirl.create(:unique_user)
          user_idea = @another_user.create_new_idea!(:content => 'ana are mere', :privacy => Privacy::Values[:public])
          @idea_list.add_idea_as user_idea.idea, Privacy::Values[:public]
        end

        it 'should add an idea to the user\'s ideas' do
          @user.idea_lists.first.ideas.first.idea.content.should == 'ana are mere'
        end

        it 'should add the idea to the idea list' do
          user = User.find(@user.id)
          user.ideas.first.id.should == @user.idea_lists.first.ideas.first.id
        end

        it 'should increment the ideas_count' do
          @user.idea_lists.first.ideas_count.should == 1
        end
      end
    end

    describe 'remove idea' do
      before do
        @user = FactoryGirl.create(:unique_user)
        @idea_list = @user.idea_lists.create(@attr)
        @user.create_new_idea!(:content => 'ana are mere', :privacy => Privacy::Values[:public])
        idea = Idea.first
        @idea_list.add_idea_as idea
        @idea_list.remove_idea idea
      end

      it 'should remove the idea from the idea list' do
        @user.idea_lists.first.ideas.should be_empty
      end

      it 'should not remove the idea from the user\'s ideas' do
        user = User.find(@user.id)
        user.ideas.first.id.should_not be_nil
      end

      it 'should decrement the ideas_count' do
        @user.idea_lists.first.ideas_count.should == 0
      end
    end
  end
end
