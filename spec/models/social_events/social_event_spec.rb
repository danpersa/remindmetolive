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
        @social_event2 = FactoryGirl.create :social_event, :created_by => user, :updated_at => 1.days.ago
        @social_event3 = FactoryGirl.create :social_event, :created_by => user, :updated_at => 3.days.ago
        @social_event4 = FactoryGirl.create :share_idea_social_event, :users => [user], :updated_at => 4.days.ago
        @social_events = SocialEvent.of_user(user)
      end

      it 'should have the correct size' do
        @social_events.size.should == 4
      end

      it 'should not include social events of other users' do
        @social_events.should_not include(@other_social_event)
      end

      it 'should include the user\'s social events in the right order' do
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
        @social_events = SocialEvent.public_of_user(user)
      end

      it 'should have the correct size' do
        @social_events.size.should == 3
      end

      it 'should not include social events of other users' do
        @social_events.should_not include(@other_social_event)
      end

      it 'should not include private social events' do
        @social_events.should_not include(@private_social_event)
      end

      it 'should include the user\'s social events in the right order' do
        @social_events.should == [@social_event2, @social_event1, @social_event3]
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
        @social_events = SocialEvent.own_or_public_of_users_followed_by(user)
      end

      it 'should have the correct size' do
        @social_events.size.should == 5
      end

      it 'should not include social events of users others then the followed users' do
        @social_events.should_not include(@social_event3)
      end

      it 'should not include private social events of followed users' do
        @social_events.should_not include(@private_social_event)
      end

      it 'should include the followed user\'s social events and own events in the right order' do
        @social_events.entries.should == [@own_social_event0, @social_event2, @social_event1, @social_event0, @own_social_event1]
      end
    end
  end
end
