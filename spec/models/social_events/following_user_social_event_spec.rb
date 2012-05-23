require 'spec_helper'

describe FollowingUserSocialEvent do
  describe 'methods' do

    describe 'all following social events created by an user today, with a specified following user' do

      let :user do
        FactoryGirl.create :unique_user
      end

      let :followed do
        FactoryGirl.create :unique_user
      end

      let :another_user do
        FactoryGirl.create :unique_user
      end

      before do
        @following_user_social_event = FactoryGirl.create :following_user_social_event, 
                                               :created_by => user,
                                               :users => [followed, another_user]
        @result = FollowingUserSocialEvent.created_by_user_today_with_following user, followed
      end

      it 'should not be nil' do
        @result.should_not be_nil
      end

      it 'should return the right following user social event' do
        @result.created_at.utc.should == @following_user_social_event.created_at.utc
      end
    end

    describe 'all following social events created by an user, created today' do
      let :user do
        FactoryGirl.create :unique_user
      end

      let :followed do
        FactoryGirl.create :unique_user
      end

      let :another_user do
        FactoryGirl.create :unique_user
      end

      before do
        @following_user_social_event = FactoryGirl.create :following_user_social_event, 
                                               :created_by => user,
                                               :users => [followed, another_user]
        @result = FollowingUserSocialEvent.created_by_user_today user
      end

      it 'should not be nil' do
        @result.should_not be_nil
      end

      it 'should return the right following user social event' do
        @result.created_at.utc.should == @following_user_social_event.created_at.utc
      end
    end

    describe 'create a new following user social event' do
      let :user do
        FactoryGirl.create :unique_user
      end

      let :followed do
        FactoryGirl.create :unique_user
      end

      let :another_user do
        FactoryGirl.create :unique_user
      end

      before do
        @result = FollowingUserSocialEvent.create! user, followed
      end

      it 'should be persisted in the database' do
        FollowingUserSocialEvent.find(@result.id).should_not be_nil
      end

      it 'should be the right one' do
        FollowingUserSocialEvent.find(@result.id).created_by.should == user
      end

      it 'should not create two events for the same user in the same day' do
        FollowingUserSocialEvent.create! user, another_user
        today = Time.now.utc
        start_time = Time.utc(today.year, today.month, today.day)
        end_time = Time.utc(today.year, today.month, today.day + 1)
        events = FollowingUserSocialEvent.where(
                                   {:created_at => {'$gte' => start_time,'$lt' => end_time},
                                    :created_by_id => user.id})
        events.entries.size.should == 1
      end

      it 'should add a new user in the followed users array' do
        FollowingUserSocialEvent.create! user, another_user
        FollowingUserSocialEvent.find(@result.id).users.size.should == 2
      end

      it 'should increment the followed users count' do
        FollowingUserSocialEvent.create! user, another_user
        FollowingUserSocialEvent.find(@result.id).users_count.should == 2
      end

      it 'should not add the followed user twice in the same day' do
        FollowingUserSocialEvent.create! user, followed
        FollowingUserSocialEvent.find(@result.id).users.size.should == 1
      end

      it 'should not increment the followed users count if we try to add the same user more than once' do
        FollowingUserSocialEvent.create! user, followed
        FollowingUserSocialEvent.find(@result.id).users_count.should == 1
      end

      it 'should create a new social event if the day has passed' do
        tomorrow = Time.now.tomorrow
        Time.stub!(:now).and_return(tomorrow)
        FollowingUserSocialEvent.create! user, another_user
        events = FollowingUserSocialEvent.where(:created_by_id => user.id)
        events.entries.size.should == 2
      end
    end

    describe 'unfollow' do
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
        FollowingUserSocialEvent.unfollow! another_user, followed
        FollowingUserSocialEvent.find(following_event.id).should_not be_nil
        FollowingUserSocialEvent.find(following_event.id).users.count.should == 1
      end

      describe 'one followed user' do
        it 'should destroy the entire event' do
          following_event = FollowingUserSocialEvent.create! user, followed
          FollowingUserSocialEvent.unfollow! user, followed
          lambda { FollowingUserSocialEvent.find(following_event.id) }.should raise_error(Mongoid::Errors::DocumentNotFound)
        end
      end

      describe 'more followed users' do
        before do
          following_event = FollowingUserSocialEvent.create! user, followed
          FollowingUserSocialEvent.create! user, another_user
          @following_event = FollowingUserSocialEvent.find(following_event.id)
          FollowingUserSocialEvent.unfollow! user, followed
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
          FollowingUserSocialEvent.unfollow! user, followed
          @following_event = FollowingUserSocialEvent.find(following_event.id)
        end

        it 'should keep the first_users collection size constant' do
          @following_event.first_users.size.should == FollowingUserSocialEvent::MAX_FIRST_USERS
        end
      end
    end
  end
end
