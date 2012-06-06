require 'spec_helper'

describe SocialEvent do

  describe 'creation' do
    it 'should create a new instance given valid attributes' do
      social_event = FactoryGirl.build :social_event
      social_event.save.should == true
    end
  end

  describe 'fields' do
    describe 'privacy field' do
      let :social_event do
        SocialEvent.new
      end

      it 'should exist' do
        social_event.should respond_to :privacy
      end

      it 'should reject values other than nil, public or private' do
        social_event = FactoryGirl.build :social_event, :privacy => 3
        social_event.should_not be_valid
        social_event.errors[:privacy].include?("is not included in the list").should == true
      end
    end
  end

  describe 'associations' do
    describe 'created by association' do
      let :user do
        FactoryGirl.create :unique_user
      end

      let :social_event do
        FactoryGirl.create :social_event, :created_by => user
      end

      it 'should have a created by association' do
        social_event.should respond_to :created_by
      end

      it 'should be the correct user' do
        social_event.created_by.should == user
      end
    end
  end

  describe 'methods' do

    describe 'self.of_user' do
      let :user do
        FactoryGirl.create :unique_user
      end

      before do
        @other_social_event = FactoryGirl.create :social_event
        @social_event1 = FactoryGirl.create :social_event, :created_by => user, :updated_at => 2.days.ago
        puts @social_event1.updated_at.to_s
        @social_event2 = FactoryGirl.create :social_event, :created_by => user, :updated_at => 1.days.ago
        puts @social_event2.updated_at.to_s
        @social_event3 = FactoryGirl.create :social_event, :created_by => user, :updated_at => 3.days.ago
        puts @social_event3.updated_at.to_s
        @social_event4 = FactoryGirl.create :share_idea_social_event, :users => [user], :updated_at => 4.days.ago
        puts @social_event4.updated_at.to_s
        @social_events = SocialEvent.of_user(user).entries
        puts "XXXXX"
      end

      it 'should have the correct size' do
        @social_events.size.should == 4
      end

      it 'should not include social events of other users' do
        @social_events.should_not include(@other_social_event)
      end

      it 'should include the user\'s social events in the right order' do
        @social_events.each do |se|
          puts se.updated_at.to_s
        end
        @social_events.should == [@social_event2, @social_event1, @social_event3, @social_event4]
      end

      it 'should include social events where the user is mentioned in the users array' do
        @social_events.should include(@social_event4)
      end
    end

    describe 'public_of_user' do
      let :user do
        FactoryGirl.create :unique_user
      end

      before do
        @other_social_event = FactoryGirl.create :social_event
        @private_social_event = FactoryGirl.create :social_event, :created_by => user, :updated_at => 1.days.ago, :privacy => Privacy::Values[:private]
        @social_event1 = FactoryGirl.create :social_event, :created_by => user, :updated_at => 3.days.ago
        @social_event2 = FactoryGirl.create :social_event, :created_by => user, :updated_at => 2.days.ago
        @social_event3 = FactoryGirl.create :social_event, :created_by => user, :updated_at => 4.days.ago
        @social_event4 = FactoryGirl.create :share_idea_social_event, :users => [user], :updated_at => 4.days.ago
        @social_events = SocialEvent.public_of_user(user)
      end

      it 'should have the correct size' do
        @social_events.size.should == 4
      end

      it 'should not include social events of other users' do
        @social_events.should_not include(@other_social_event)
      end

      it 'should not include private social events' do
        @social_events.should_not include(@private_social_event)
      end

      it 'should include the user\'s social events in the right order' do
        @social_events.should == [@social_event2, @social_event1, @social_event3, @social_event4]
      end
    end

    describe 'public_of_users_followed_by' do
      let :user do
        FactoryGirl.create :unique_user
      end

      before do
        # we have some users, followed by the user
        user1 = FactoryGirl.create :unique_user
        user2 = FactoryGirl.create :unique_user
        user3 = FactoryGirl.create :unique_user
        user.follow! user1
        user.follow! user2
        @private_social_event = FactoryGirl.create :social_event, :created_by => user1, :updated_at => 1.days.ago, :privacy => Privacy::Values[:private]
        @social_event0 = FactoryGirl.create :social_event, :created_by => user2, :updated_at => 4.days.ago
        @social_event1 = FactoryGirl.create :social_event, :created_by => user1, :updated_at => 3.days.ago
        @social_event2 = FactoryGirl.create :social_event, :created_by => user2, :updated_at => 2.days.ago
        @social_event3 = FactoryGirl.create :social_event, :created_by => user3, :updated_at => 4.days.ago
        @social_event4 = FactoryGirl.create :share_idea_social_event, :users => [user], :updated_at => 5.days.ago
        @social_events = SocialEvent.public_of_users_followed_by(user)
      end

      it 'should have the correct size' do
        @social_events.size.should == 3
      end

      it 'should not include social events of users others then the followed users' do
        @social_events.should_not include(@social_event3)
      end

      it 'should not include private social events of followed users' do
        @social_events.should_not include(@private_social_event)
      end

      it 'should include the followed user\'s social events in the right order' do
        @social_events.should == [@social_event2, @social_event1, @social_event0]
      end
    end

    describe 'own_or_public_of_users_followed_by' do
      let :user do
        FactoryGirl.create :unique_user
      end

      before do
        # we have some users, followed by the user
        user1 = FactoryGirl.create :unique_user
        user2 = FactoryGirl.create :unique_user
        user3 = FactoryGirl.create :unique_user
        user.follow! user1
        user.follow! user2
        @private_social_event = FactoryGirl.create :social_event, :created_by => user1, :updated_at => 1.days.ago, :privacy => Privacy::Values[:private]
        @own_social_event0 = FactoryGirl.create :social_event, :created_by => user, :updated_at => 1.days.ago
        @own_social_event1 = FactoryGirl.create :social_event, :created_by => user, :updated_at => 5.days.ago
        @social_event0 = FactoryGirl.create :social_event, :created_by => user2, :updated_at => 4.days.ago
        @social_event1 = FactoryGirl.create :social_event, :created_by => user1, :updated_at => 3.days.ago
        @social_event2 = FactoryGirl.create :social_event, :created_by => user2, :updated_at => 2.days.ago
        @social_event3 = FactoryGirl.create :social_event, :created_by => user3, :updated_at => 4.days.ago
        @social_event4 = FactoryGirl.create :share_idea_social_event, :users => [user], :updated_at => 5.days.ago
        @social_events = SocialEvent.own_or_public_of_users_followed_by(user)
      end

      it 'should have the correct size' do
        @social_events.size.should == 6
      end

      it 'should not include social events of users others then the followed users' do
        @social_events.should_not include(@social_event3)
      end

      it 'should not include private social events of followed users' do
        @social_events.should_not include(@private_social_event)
      end

      it 'should include the followed user\'s social events and own events in the right order' do
        @social_events.entries.should == [@own_social_event0, @social_event2, @social_event1, @social_event0, @own_social_event1, @social_event4]
      end
    end

    describe 'remove user from following social event' do
      let :user do
        FactoryGirl.create :unique_user
      end

      let :followed do
        FactoryGirl.create :unique_user
      end

      let :another_user do
        FactoryGirl.create :unique_user
      end

      it 'should do nothing if the following event does not contain the parameter user' do
        following_event = FollowingUserSocialEvent.create! user, followed
        following_event.remove_user another_user
        FollowingUserSocialEvent.find(following_event.id).should_not be_nil
        FollowingUserSocialEvent.find(following_event.id).users.count.should == 1
      end

      describe 'one followed user' do
        it 'should destroy the entire event' do
          following_event = FollowingUserSocialEvent.create! user, followed
          following_event.remove_user followed
          lambda { FollowingUserSocialEvent.find(following_event.id) }.should raise_error(Mongoid::Errors::DocumentNotFound)
        end
      end

      describe 'more followed users' do
        before do
          following_event = FollowingUserSocialEvent.create! user, followed
          FollowingUserSocialEvent.create! user, another_user
          @following_event = FollowingUserSocialEvent.find(following_event.id)
          @following_event.remove_user followed
          @following_event = FollowingUserSocialEvent.find(following_event.id)
        end

        it 'should not delete the following event' do
          @following_event.should_not be_nil
        end

        it 'should remove the user from the users collection' do
          @following_event.users.include?(followed).should == false
        end

        it 'should decrement the users count field' do
          @following_event.users_count.should == 1
        end

        describe 'user is also in the first_users collection' do
          it 'should remove the user from the first_users collection' do
            @following_event.first_users.include?(followed).should == false
          end

          it 'should decrement first_users_count' do
            @following_event.first_users_count.should == 1
          end
        end
      end

      describe 'first_users auto repopulate' do

        before do
          following_event = FollowingUserSocialEvent.create! user, followed
          FollowingUserSocialEvent.create! user, another_user
          FollowingUserSocialEvent.create! user, FactoryGirl.create(:unique_user)
            FollowingUserSocialEvent.create! user, FactoryGirl.create(:unique_user)
          @following_event = FollowingUserSocialEvent.find(following_event.id)
          @following_event.remove_user followed
          @following_event = FollowingUserSocialEvent.find(following_event.id)
        end

        it 'should keep the first_users collection size constant' do
          @following_event.first_users.size.should == FollowingUserSocialEvent::MAX_FIRST_USERS
        end
      end
    end
  end
end
