require 'spec_helper'

describe UserIdea do

  let :user do
    FactoryGirl.create :simple_user
  end

  let :idea do
    FactoryGirl.create :idea
  end

  let :attr do
    { :privacy => Privacy::Values[:public],
      :idea_id => idea.id
    }
  end

  describe 'creation' do
    it 'should create a new instance given valid attributes' do
      user.ideas.create!(attr)
    end
  end

  describe 'fields' do
    describe 'privacy field' do

      it 'should exist' do
        user_idea = FactoryGirl.build :user_idea
        user_idea.should respond_to :privacy
      end

      describe 'when validating presence' do
        it 'should require a privacy' do
          user_idea = user.ideas.build :privacy => nil
          user_idea.should_not be_valid
          user_idea.errors[:privacy].include?("can't be blank").should == true
        end
      end

      it 'should reject values other than public or private' do
        user_idea = user.ideas.build :privacy => 3
        user_idea.should_not be_valid
        user_idea.errors[:privacy].include?("is not included in the list").should == true
      end
    end

    describe 'reminder_date field' do

      it 'should exist' do
        user_idea = FactoryGirl.build :simple_user_idea
        user_idea.should respond_to :reminder_date
      end

      it 'should not be in the past' do
        user_idea = FactoryGirl.build :simple_user_idea, :reminder_date => 2.days.ago
        user_idea.should_not be_valid
        user_idea.errors[:reminder_date].include?("can't be in the past").should == true
      end
    end

    describe 'it should have a reminder_created_at field' do
      it 'should exist' do
        user_idea = FactoryGirl.build :simple_user_idea
        user_idea.should respond_to :reminder_created_at
      end

      it 'should have a default value' do
        user_idea = user.ideas.build :privacy => Privacy::Values[:public]
        user_idea.reminder_created_at.should_not be_nil
      end
    end
  end

  describe 'associations' do
    let :user_idea do
      user.ideas.build(attr)
    end

    describe 'user association' do
      it 'should have an user association' do
        user_idea.should respond_to :user
      end

      it 'should be the correct user' do
        user_idea.user.should == user
      end
    end

    describe 'idea association' do
      it 'should have an idea association' do
        user_idea.should respond_to :idea
      end

      it 'should be the correct idea' do
        user_idea.idea.should == idea
      end

      it 'should reject user ideas without idea' do
        user_idea = FactoryGirl.build :user_idea, :idea => nil
        user_idea.should_not be_valid
        user_idea.errors[:idea].include?("can't be blank").should == true
      end
    end
  end

  
  describe '#set_reminder' do

    it 'should have an set_reminder method' do
      user_idea = FactoryGirl.build :simple_user_idea
      user_idea.should respond_to :set_reminder
    end

    it 'should initilize the reminder_created_at attribute' do
      user_idea = FactoryGirl.build :simple_user_idea
      reminder_date = Date.new
      user_idea.set_reminder reminder_date
      user_idea.reminder_created_at.should_not be_nil
    end
  end

  describe '#find_by_id' do
    let :user_idea do
      FactoryGirl.create :simple_user_idea
    end

    it 'should find the idea' do
      result_user_idea = UserIdea.find_by_id user_idea.id
      result_user_idea.should_not be_nil
    end
  end

  describe '#delete_all_for_idea' do
    before do
      user = FactoryGirl.create :unique_user
      idea = FactoryGirl.create :idea, created_by: user
      @user_idea1 = FactoryGirl.create :user_idea, idea: idea
      @user_idea2 = FactoryGirl.create :user_idea, idea: idea
      @user_idea3 = FactoryGirl.create :user_idea
      UserIdea.delete_all_for_idea idea
    end

    it 'should delete the user ideas for the specified idea' do
      UserIdea.where(_id: @user_idea1.id).entries.should be_empty
      UserIdea.where(_id: @user_idea2.id).entries.should be_empty
    end

    it 'should not delete the user ideas for other ideas' do
      UserIdea.where(_id: @user_idea3.id).entries.should_not be_empty
    end
  end

  describe '#delete_all_for' do
    before do
      user = FactoryGirl.create :unique_user
      @user_idea1 = FactoryGirl.create :user_idea, user: user
      @user_idea2 = FactoryGirl.create :user_idea, user: user
      @user_idea3 = FactoryGirl.create :user_idea
      UserIdea.delete_all_for user
    end

    it 'should destroy the user\'s user ideas' do
      UserIdea.where(_id: @user_idea1.id).entries.should be_empty
      UserIdea.where(_id: @user_idea2.id).entries.should be_empty
    end

    it 'should not destroy other user ideas' do
      UserIdea.where(_id: @user_idea3.id).entries.should_not be_empty
    end
  end

end
