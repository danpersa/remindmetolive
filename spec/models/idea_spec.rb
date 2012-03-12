require 'spec_helper'

describe Idea do

  let :attr do
    attr = { :content => "value for content", :privacy => Privacy::Values[:public] }
  end

  describe 'creation' do
    it 'should create a new instance given valid attributes' do
      idea = Factory.build :simple_idea
      idea.save.should == true
    end
  end

  describe 'field validation' do
    describe 'content field' do
      describe 'when validating presence' do
        it 'should require nonblank name' do
          idea = Idea.new(attr.merge(:content => "  "))
          idea.should_not be_valid
          idea.errors[:content].include?("can't be blank").should == true
        end
      end

      describe 'when validating length' do
        context 'too short' do
          it 'should reject short content' do
            idea = Idea.new(attr.merge(:content => 'a'))
            idea.should_not be_valid
            idea.errors[:content].should == ['is too short (minimum is 3 characters)']
          end
        end

        context 'too long' do
          it 'should reject long content' do
            idea = Idea.new(attr.merge(:content => 'a' * 256))
            idea.should_not be_valid
            idea.errors[:content].should == ['is too long (maximum is 255 characters)']
          end
        end
      end
    end

    describe 'users_marked_the_idea_good_count field' do
      let :idea do
        Idea.new
      end

      it 'should exist' do
        idea.should respond_to :users_marked_the_idea_good_count
      end

      it 'should be 0 by default' do
        idea.users_marked_the_idea_good_count.should == 0
      end
    end

    describe 'users_marked_the_idea_good_done field' do
      let :idea do
        Idea.new
      end

      it 'should exist' do
        idea.should respond_to :users_marked_the_idea_done_count
      end

      it 'should be 0 by default' do
        idea.users_marked_the_idea_done_count.should == 0
      end
    end

    describe 'privacy field' do
      let :idea do
        Idea.new
      end

      it 'should exist' do
        idea.should respond_to :privacy
      end

      describe 'when validating presence' do
        it 'should require a privacy' do
          idea = Factory.build :simple_idea, :privacy => nil
          idea.should_not be_valid
          idea.errors[:privacy].include?("can't be blank").should == true
        end
      end

      it 'should reject values other than public or private' do
        idea = Factory.build :simple_idea, :privacy => 3
        idea.should_not be_valid
        idea.errors[:privacy].include?("is not included in the list").should == true
      end
    end
  end

  describe 'associations' do

    describe 'created by association' do
      let :user do
        Factory :unique_user
      end

      let :idea do
        Factory :simple_idea, :created_by => user, :owned_by => user
      end

      it 'should have a created by association' do
        idea.should respond_to :created_by
      end

      it 'should be the correct user' do
        idea.created_by.should == user
      end
    end

    describe 'owned by association' do
      let :user do
        Factory :unique_user
      end

      let :idea do
        Factory :simple_idea, :created_by => user, :owned_by => user
      end

      it 'should have an owned by association' do
        idea.should respond_to :owned_by
      end

      it 'should be the correct user' do
        idea.owned_by.should == user
      end
    end

    describe 'users that marked the idea as good association' do
      let :idea do
        Factory :simple_idea
      end

      it 'should have a users_marked_the_idea_good attribute' do
        idea.should respond_to(:users_marked_the_idea_good)
      end

      it 'should have the right associated users' do
        user = Factory :simple_user
        idea.users_marked_the_idea_good.push user
        idea.users_marked_the_idea_good.include?(user).should == true
      end
    end

    describe 'users that marked the idea as done association' do
      let :idea do
        Factory :simple_idea
      end

      it 'should have a users_marked_the_idea_done attribute' do
        idea.should respond_to(:users_marked_the_idea_done)
      end

      it 'should have the right associated users' do
        user = Factory :simple_user
        idea.users_marked_the_idea_done.push user
        idea.users_marked_the_idea_done.include?(user).should == true
      end
    end
  end

  describe 'methods' do
    let :idea do
      Factory :simple_idea
    end

    let :user do
      Factory :simple_user
    end

    describe 'mark_as_good_by!' do
      before do
        idea.mark_as_good_by! user
      end

      it 'should increment the users_marked_the_idea_good_count counter' do
        idea.users_marked_the_idea_good_count.should == 1
      end

      it 'should add a new user in the users_marked_the_idea_good array' do
        idea.users_marked_the_idea_good.include?(user).should == true
      end
    end

    describe 'marked_as_good_by?' do
      before do
        idea.mark_as_good_by! user
      end

      it 'should be true if the user marked the idea as good' do
        idea.marked_as_good_by?(user).should == true
      end

      it 'should not be true if the user didn\'t mark the idea' do
        idea.marked_as_good_by?(Factory.build :user).should_not == true
      end
    end

    describe 'mark_as_done_by' do
      before do
        idea.mark_as_done_by! user
      end

      it 'should increment the users_marked_the_idea_done_count counter' do
        idea.users_marked_the_idea_done_count.should == 1
      end

      it 'should add a new user in the users_marked_the_idea_done array' do
        idea.users_marked_the_idea_done.include?(user).should == true
      end
    end

    describe 'marked_as_done_by?' do
      before do
        idea.mark_as_done_by! user
      end

      it 'should be true if the user marked the idea as done' do
        idea.marked_as_done_by?(user).should == true
      end

      it 'should not be true if the user didn\'t mark the idea' do
        idea.marked_as_done_by?(Factory.build :user).should_not == true
      end
    end

    describe 'public?' do
      it 'should return true if the privacy field is public' do
        idea.should be_public
      end

      it 'should return false if the privacy field is private' do
        idea.privacy = Privacy::Values[:private]
        idea.should_not be_public
      end
    end

    describe 'private?' do
      it 'should return true if the privacy field is private' do
        idea.privacy = Privacy::Values[:private]
        idea.should be_private
      end

      it 'should return false if the privacy field is public' do
        idea.privacy = Privacy::Values[:public]
        idea.should_not be_private
      end
    end


  end
end
