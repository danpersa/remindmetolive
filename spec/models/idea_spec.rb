require 'spec_helper'

describe Idea do

  let :attr do
    attr = { :content => "value for content", :privacy => Privacy::Values[:public] }
  end

  describe 'creation' do
    it 'should create a new instance given valid attributes' do
      idea = FactoryGirl.build :simple_idea
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
          idea = FactoryGirl.build :simple_idea, :privacy => nil
          idea.should_not be_valid
          idea.errors[:privacy].include?("can't be blank").should == true
        end
      end

      it 'should reject values other than public or private' do
        idea = FactoryGirl.build :simple_idea, :privacy => 3
        idea.should_not be_valid
        idea.errors[:privacy].include?("is not included in the list").should == true
      end
    end
  end

  describe 'associations' do

    describe 'created by association' do
      let :user do
        FactoryGirl.create :unique_user
      end

      let :idea do
        FactoryGirl.create :simple_idea, :created_by => user, :owned_by => user
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
        FactoryGirl.create :unique_user
      end

      let :idea do
        FactoryGirl.create :simple_idea, :created_by => user, :owned_by => user
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
        FactoryGirl.create :simple_idea
      end

      it 'should have a users_marked_the_idea_good attribute' do
        idea.should respond_to(:users_marked_the_idea_good)
      end

      it 'should have the right associated users' do
        user = FactoryGirl.create :simple_user
        idea.users_marked_the_idea_good.push user
        idea.users_marked_the_idea_good.include?(user).should == true
      end
    end

    describe 'users that marked the idea as done association' do
      let :idea do
        FactoryGirl.create :simple_idea
      end

      it 'should have a users_marked_the_idea_done attribute' do
        idea.should respond_to(:users_marked_the_idea_done)
      end

      it 'should have the right associated users' do
        user = FactoryGirl.create :simple_user
        idea.users_marked_the_idea_done.push user
        idea.users_marked_the_idea_done.include?(user).should == true
      end
    end

    describe 'user ideas association' do
      let :idea do
        FactoryGirl.create :idea
      end

      it 'should have a user_ideas attribute' do
        idea.should respond_to(:user_ideas)
      end

      it 'should have the right associated user_ideas' do
        user_idea = FactoryGirl.create :user_idea, :idea => idea
        idea.user_ideas.should include(user_idea)
      end
    end
  end

  describe 'methods' do
    before  do
      @idea = FactoryGirl.create :simple_idea
      @user = FactoryGirl.create :simple_user
    end

    describe '#mark_as_good_by!' do
      before do
        @idea.mark_as_good_by! @user
      end

      it 'should increment the users_marked_the_idea_good_count counter' do
        @idea.users_marked_the_idea_good_count.should == 1
      end

      it 'should add a new user in the users_marked_the_idea_good array' do
        @idea.users_marked_the_idea_good.include?(@user).should == true
      end

      context 'already marked as good' do
        before do
          @idea.mark_as_good_by! @user
        end

        it 'should not increment the users_marked_the_idea_good_count counter' do
          @idea.users_marked_the_idea_good_count.should == 1 
        end
      end
    end

    describe '#marked_as_good_by?' do
      before do
        @idea.mark_as_good_by! @user
      end

      it 'should be true if the user marked the idea as good' do
        @idea.marked_as_good_by?(@user).should == true
      end

      it 'should not be true if the user didn\'t mark the idea' do
        @idea.marked_as_good_by?(FactoryGirl.build :user).should_not == true
      end
    end

    describe '#unmark_as_good_by!' do
      before  do
        @idea.mark_as_good_by! @user
        @idea.unmark_as_good_by! @user
      end

      it 'should decrement the users_marked_the_idea_good_count counter' do
        @idea.users_marked_the_idea_good_count.should == 0
      end

      it 'should remove the user in the users_marked_the_idea_good array' do
        @idea.users_marked_the_idea_good.include?(@user).should_not == true
      end

      context 'not marked as good' do
        before do
          @idea.unmark_as_good_by! @user
        end

        it 'should not decrement the users_marked_the_idea_good_count counter' do
          @idea.users_marked_the_idea_good_count.should == 0
        end
      end
    end

    describe '#mark_as_done_by!' do
      before do
        @idea.mark_as_done_by! @user
      end

      it 'should increment the users_marked_the_idea_done_count counter' do
        @idea.users_marked_the_idea_done_count.should == 1
      end

      it 'should add a new user in the users_marked_the_idea_done array' do
        @idea.users_marked_the_idea_done.include?(@user).should == true
      end

      context 'already marked as done' do
        before do
          @idea.mark_as_done_by! @user
        end

        it 'should not increment the users_marked_the_idea_done_count counter' do
          @idea.users_marked_the_idea_done_count.should == 1 
        end
      end
    end

    describe '#unmark_as_done_by!' do
      before do
        @idea.mark_as_done_by! @user
        @idea.unmark_as_done_by! @user
      end

      it 'should decrement the users_marked_the_idea_done_count counter' do
        @idea.users_marked_the_idea_done_count.should == 0
      end

      it 'should remove the user in the users_marked_the_idea_done array' do
        @idea.users_marked_the_idea_done.include?(@user).should_not == true
      end

      context 'not marked as done' do
        before do
          @idea.unmark_as_done_by! @user
        end

        it 'should not decrement the users_marked_the_idea_done_count counter' do
          @idea.users_marked_the_idea_done_count.should == 0
        end
      end
    end

    describe '#marked_as_done_by?' do
      before do
        @idea.mark_as_done_by! @user
      end

      it 'should be true if the user marked the idea as done' do
        @idea.marked_as_done_by?(@user).should == true
      end

      it 'should not be true if the user didn\'t mark the idea' do
        @idea.marked_as_done_by?(FactoryGirl.build :user).should_not == true
      end
    end

    describe '#public?' do
      it 'should return true if the privacy field is public' do
        @idea.should be_public
      end

      it 'should return false if the privacy field is private' do
        @idea.privacy = Privacy::Values[:private]
        @idea.should_not be_public
      end
    end

    describe '#private?' do
      it 'should return true if the privacy field is private' do
        @idea.privacy = Privacy::Values[:private]
        @idea.should be_private
      end

      it 'should return false if the privacy field is public' do
        @idea.privacy = Privacy::Values[:public]
        @idea.should_not be_private
      end
    end

    describe '#public_user_ideas' do

      before do
        @idea = FactoryGirl.create :idea
        @public_user_idea = FactoryGirl.create :user_idea, 
                                    :idea => @idea, 
                                    :privacy =>  Privacy::Values[:public]
        @private_user_idea = FactoryGirl.create :user_idea, 
                                     :idea => @idea, 
                                     :privacy =>  Privacy::Values[:private]
      end

      it 'should return the public user ideas' do
        @idea.public_user_ideas.should include(@public_user_idea)
      end

      it 'should not return the private user ideas' do
        @idea.public_user_ideas.should_not include(@private_user_idea)
      end
    end

    describe '#public_user_ideas_of_users_followed_by' do

      before do
        @current_user = FactoryGirl.create :unique_user
        followed_user1 = FactoryGirl.create :unique_user
        followed_user2 = FactoryGirl.create :unique_user
        other_user = FactoryGirl.create :unique_user
        @current_user.follow! followed_user1
        @current_user.follow! followed_user2
        @current_user = User.find @current_user.id
        @idea = FactoryGirl.create :idea
        @public_user_idea_of_followed_user = FactoryGirl.create :user_idea,
                                                                :idea => @idea,
                                                                :privacy =>  Privacy::Values[:public],
                                                                :user => followed_user1
        @private_user_idea_of_followed_user = FactoryGirl.create :user_idea,
                                                                 :idea => @idea,
                                                                 :privacy =>  Privacy::Values[:private],
                                                                 :user => followed_user2
        @public_user_idea_of_other_user = FactoryGirl.create :user_idea,
                                                             :idea => @idea,
                                                             :privacy =>  Privacy::Values[:public],
                                                             :user => other_user
      end

      it 'should include the public user ideas of the users followed by the current user' do
        @idea.public_user_ideas_of_users_followed_by(@current_user)
             .should include(@public_user_idea_of_followed_user)
      end

      it 'should not include the private user ideas of the users followed by the current user' do
        @idea.public_user_ideas_of_users_followed_by(@current_user)
             .should_not include(@private_user_idea_of_followed_user)
      end

      it 'should not include the public user ideas of the users not followed by the current user' do
        @idea.public_user_ideas_of_users_followed_by(@current_user).entries
             .should_not include(@public_user_idea_of_other_user)
      end
    end

    describe '#shared_by_many_users' do
      before do
        current_user = FactoryGirl.create :unique_user
        @idea = FactoryGirl.create :idea, :created_by => current_user,
                        :owned_by => current_user
        user_idea = FactoryGirl.create :user_idea,
                            :idea => @idea,
                            :privacy =>  Privacy::Values[:public],
                            :user => current_user
      end

      context 'shared only by the owner' do
        it 'should be false' do
          @idea.shared_by_many_users?.should_not be_true
        end
      end

      context 'there are two users sharing the idea' do
        before do
          second_user_idea = FactoryGirl.create :user_idea,
                                     :idea => @idea,
                                     :privacy =>  Privacy::Values[:public]
        end

        it 'should be true' do
          @idea.shared_by_many_users?.should be_true
        end
      end
    end
  end

  describe '#idea_lists_of' do

    it 'should return the correct idea lists' do
      @user = FactoryGirl.create(:unique_user)
      @idea_list1 = @user.idea_lists.create({:name => "The Bucket List"})
      @idea_list2 = @user.idea_lists.create({:name => "The Final List"})
      idea = @user.create_new_idea!(:content => 'ana are mere',
                                    :privacy => Privacy::Values[:public]).idea
      @idea_list1.add_idea_as idea, Privacy::Values[:public]
      @idea_list2.add_idea_as idea, Privacy::Values[:public]
      idea_lists_of_user = idea.idea_lists_of(@user)
      idea.idea_lists_of(@user).should_not be_nil
      idea.idea_lists_of(@user).size.should == 2
    end
  end

  describe '#put_in_idea_lists_of_user' do
    before do
      @user = FactoryGirl.create(:unique_user)
      @idea_list1 = @user.idea_lists.create({:name => "The Bucket List"})
      @idea_list2 = @user.idea_lists.create({:name => "The Final List"})
      @idea_list3 = @user.idea_lists.create({:name => "The Final List1"})
      idea = @user.create_new_idea!(:content => 'ana are mere',
                                    :privacy => Privacy::Values[:public]).idea
      @idea_list1.add_idea_as idea, Privacy::Values[:public]
      @idea_list2.add_idea_as idea, Privacy::Values[:public]

      idea.put_in_idea_lists_of_user [@idea_list1.id.to_s, @idea_list3.id.to_s], @user

      idea = Idea.find idea.id

      @idea_list_ids = idea.idea_lists_of(@user).entries.map{|idea_list| idea_list.id}
      # puts 'final result'
      # puts @idea_list_ids
      
    end

    it 'should have the correct size' do
      @idea_list_ids.size.should == 2
    end

    it 'should include the list that he was already added in, but given as a list to be added again' do
      @idea_list_ids.should include(@idea_list1.id)
    end

    it 'should not include the list he was in, but it was not given as a list to be added' do
      @idea_list_ids.should_not include(@idea_list2.id)
    end

    it 'should include the new list' do
      @idea_list_ids.should include(@idea_list3.id)
    end
  end

  describe '#delete_all_for' do
    before do
      user = FactoryGirl.create :unique_user
      @idea1 = FactoryGirl.create :idea, created_by: user
      @idea2 = FactoryGirl.create :idea, created_by: user
      @idea3 = FactoryGirl.create :idea
      @user_idea1 = FactoryGirl.create :user_idea, idea: @idea1
      @user_idea2 = FactoryGirl.create :user_idea, idea: @idea2
      @user_idea3 = FactoryGirl.create :user_idea, idea: @idea3
      Idea.delete_all_for user
    end

    it 'should destroy the user\'s ideas' do
      Idea.where(_id: @idea1.id).entries.should be_empty
      Idea.where(_id: @idea2.id).entries.should be_empty
    end

    it 'should not destroy other ideas' do
      Idea.where(_id: @idea3.id).entries.should_not be_empty
    end

    it 'should delete the user ideas for the deleted ideas' do
      UserIdea.where(_id: @user_idea1.id).entries.should be_empty
      UserIdea.where(_id: @user_idea2.id).entries.should be_empty
    end

    it 'should not delete the user ideas for other ideas' do
      UserIdea.where(_id: @user_idea3.id).entries.should_not be_empty
    end
  end

  describe '#remove_from_mark_as_done!' do
    before  do
      @user = FactoryGirl.create :unique_user
      @other_user = FactoryGirl.create :unique_user
      @idea1 = FactoryGirl.create :simple_idea
      @idea2 = FactoryGirl.create :simple_idea
      @idea1.mark_as_done_by! @user
      @idea1.mark_as_done_by! @other_user
      @idea2.mark_as_done_by! @user
      Idea.remove_from_mark_as_done @user
      @idea1 = Idea.find @idea1.id
      @idea2 = Idea.find @idea2.id
    end

    it 'should decrement the users_marked_the_idea_done_count counter' do
      @idea1.users_marked_the_idea_done_count.should == 1
      @idea2.users_marked_the_idea_done_count.should == 0
    end

    it 'should remove the user in the users_marked_the_idea_done array' do
      @idea1.users_marked_the_idea_done.should_not include(@user)
      @idea1.users_marked_the_idea_done.should include(@other_user)
      @idea2.users_marked_the_idea_done.should_not include(@user)
    end
  end

  describe '#remove_from_mark_as_good!' do
    before  do
      @user = FactoryGirl.create :unique_user
      @other_user = FactoryGirl.create :unique_user
      @idea1 = FactoryGirl.create :simple_idea
      @idea2 = FactoryGirl.create :simple_idea
      @idea1.mark_as_good_by! @user
      @idea1.mark_as_good_by! @other_user
      @idea2.mark_as_good_by! @user
      Idea.remove_from_mark_as_good @user
      @idea1 = Idea.find @idea1.id
      @idea2 = Idea.find @idea2.id
    end

    it 'should decrement the users_marked_the_idea_good_count counter' do
      @idea1.users_marked_the_idea_good_count.should == 1
      @idea2.users_marked_the_idea_good_count.should == 0
    end

    it 'should remove the user in the users_marked_the_idea_good array' do
      @idea1.users_marked_the_idea_good.should_not include(@user)
      @idea1.users_marked_the_idea_good.should include(@other_user)
      @idea2.users_marked_the_idea_good.should_not include(@user)
    end
  end
end
