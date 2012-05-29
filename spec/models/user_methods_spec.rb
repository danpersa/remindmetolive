require 'spec_helper'

describe User do

  before(:each) do
    @attr = {
      :username => 'Example',
      :email => 'user@example.com',
      :password => 'foobar',
      :password_confirmation => 'foobar'
    }
  end

  describe 'following?' do
    let :user do
      FactoryGirl.build :simple_user
    end

    it 'should have a following? method' do
      user.should respond_to :following?
    end
  end

  describe 'follow!' do
    let :user do
      FactoryGirl.create :unique_user
    end

    let :followed do
      FactoryGirl.create :unique_user
    end

    before do
      user.follow!(followed)
    end

    it 'should follow another user' do
      user.should be_following(followed)
    end

    it 'should include the followed user in the following array' do
      user.following.should include(followed)
    end

    it 'should include the follower in the followers array' do
      followed.followers.should include(user)
    end

    it 'should not include the followed user in the following array more than once' do
      user.follow!(followed)
      user.following.where(_id: followed.id).count.should == 1
    end

    it 'should not include the follower user in the followers array more than once' do
      user.follow!(followed)
      followed.followers.where(_id: user.id).count.should == 1
    end

    it 'should increment the followers count for the followed user' do
      followed.followers_count.should == 1
    end

    it 'should increment the following count for the following user' do
      user.following_count.should == 1
    end
  end

  describe 'unfollow!' do
    let :user do
      FactoryGirl.create :unique_user
    end

    let :followed do
      FactoryGirl.create :unique_user
    end

    before do
      enable_social_event_notifications
      user.follow!(followed)
      user.unfollow!(followed)
    end

    after do
      disable_social_event_notifications
    end

    it 'should unfollow a user' do
      user.should_not be_following(followed)
    end

    it 'should remove the followed user from the following array' do
      user.following.should_not include(followed)
    end

    it 'should remove the followed user from database' do
      User.find(followed.id).should_not be_nil
    end

    it 'should remove the user from the followed user followers array' do
      followed.followers.should_not include(user)
    end

    it 'should remove the user from database' do
      User.find(user.id).should_not be_nil
    end

    it 'should decrement the followers count for the followed user' do
      followed.followers_count.should == 0
    end

    it 'should decrement the following count for the following user' do
      user.following_count.should == 0
    end

    it 'should remove the user from the current social event' do
      pending
    end

    it 'should delete the social event if the user is the last user in the event' do
      pending
    end
  end

  describe 'reset password' do

    let :user do
      FactoryGirl.create :activated_user
    end

    before do
      mail = mock
      mail.stub! :deliver
      UserMailer.stub!(:reset_password).and_return(mail)
    end

    it 'should have a reset password method' do
      user.should respond_to(:reset_password)
    end

    it 'should generate a password reset code' do
      user.reset_password
      user.password_reset_code.should_not be_nil
    end

    it 'should change the previous password reset code' do
      user.reset_password
      last_reset_password = user.password_reset_code
      user.reset_password
      last_reset_password.should_not == user.password_reset_code
    end

    it 'should change the previous reset password mail sent at' do
      user.reset_password
      last_reset_password_mail_sent_at = user.reset_password_mail_sent_at
      sleep(1)
      user.reset_password
      last_reset_password_mail_sent_at.should_not == user.reset_password_mail_sent_at
    end
  end

  describe 'reset_password_expired?' do

    let :user do
      FactoryGirl.create :activated_user
    end

    it 'should be expired if the reset password mail was sent two days ago' do
      user.reset_password_mail_sent_at = 2.days.ago
      user.reset_password_expired?.should == true
    end

    it 'should not be expired if the reset password mail was sent two hours ago' do
      user.reset_password_mail_sent_at = 2.hours.ago
      user.reset_password_expired?.should == false
    end
  end

  describe 'password encryption' do

    let :user do
      FactoryGirl.create :simple_user
    end

    it 'should have an encrypted password attribute' do
      user.should respond_to(:encrypted_password)
    end

    it 'should set the encrypted password' do
      user.encrypted_password.should_not be_blank
    end

    describe 'has_password? method' do

      it 'should be true if the passwords match' do
        user.has_password?('foobar').should be_true
      end

      it "should be false if the passwords don't match" do
        user.has_password?('invalid').should be_false
      end
    end

    describe 'authenticate method' do

      it 'should return nil on email/password mismatch' do
        wrong_password_user = User.authenticate('mhartl@example.com', 'wrongpass')
        wrong_password_user.should be_nil
      end

      it 'should return nil if user is blocked' do
        blocked_user = FactoryGirl.build(:activated_user, :email => 'blocked@yahoo.com', :state => 'blocked')
        blocked_user = User.authenticate(blocked_user.email, blocked_user.password)
        blocked_user.should be_nil
      end

      it 'should return nil for an email address with no user' do
        nonexistent_user = User.authenticate('bar@foo.com', 'foobar')
        nonexistent_user.should be_nil
      end

      it 'should return the user on email/password match' do
        user = FactoryGirl.create :activated_user
        matching_user = User.authenticate(user.email, user.password)
        matching_user.should == user
      end
    end
  end

  describe 'display name' do
    before do
      @user = FactoryGirl.build :user
      @profile = FactoryGirl.build :profile
      @user.profile = @profile
    end

    it 'should return the profile name' do
      @user.display_name.should == @profile.name
    end

    it 'should return the user name if no user profile name' do
      @user.profile.name = ''
      @user.display_name.should == @user.username
    end

    it 'should return the user name if no profile' do
      user = FactoryGirl.build :activated_user
      user.display_name.should == user.username
    end
  end

  describe 'create new idea' do
    let :user do
      FactoryGirl.create :user, :ideas => []
    end

    it 'should create a new idea' do
      user.create_new_idea!(:content => 'ana are mere', :privacy => Privacy::Values[:public])
      user.ideas.first.privacy.should == Privacy::Values[:public]
      Idea.first.content.should == 'ana are mere'
      Idea.first.id.should_not be_nil
    end

    it 'should not create an user idea if the idea is not valid' do
      user_idea = user.create_new_idea!(:privacy => Privacy::Values[:public])
      user_idea.should be_valid
      user_idea.idea.should_not be_valid
      user.reload
      user.ideas.should be_empty
    end

    it 'should not create an idea if the user idea is not valid' do
      user_idea = user.create_new_idea!(:content => 'ana are mere',
                                        :privacy => Privacy::Values[:public],
                                        :reminder_date => 2.days.ago)
      user_idea.should_not be_valid
      Idea.all.should be_empty
    end

    it 'should have the correct idea inside the user idea' do
      user_idea = user.create_new_idea!(:content => 'ana are mere', :privacy => Privacy::Values[:public])
      Idea.first.id.should == user_idea.idea.id
    end
  end

  describe 'create new user idea' do
    let :user do
      FactoryGirl.create :unique_user, :ideas => []
    end

    let :another_user do
      FactoryGirl.create :unique_user, :ideas => []
    end

    before do 
      user_idea = user.create_new_idea!(:content => 'ana are mere', 
                                        :privacy => Privacy::Values[:public])
      @idea = user_idea.idea
      @reminder_date = Date.new(2014)
      user_idea1 = another_user.create_user_idea! :idea_id => @idea.id,
                                                  :privacy => Privacy::Values[:public],
                                                  :reminder_date => @reminder_date
    end

    context 'when success' do

      it 'should create a new user idea' do
        another_user.ideas.should_not be_empty
      end

      it 'should be the right one' do
        another_user.ideas.first.reminder_date.should == @reminder_date
      end
    end

    context 'when failure' do
      it 'shouldn\'t create two user ideas for the same user and the same idea' do
        another_user.create_user_idea! :idea_id => @idea.id,
                                       :privacy => Privacy::Values[:public]
        @idea.user_ideas.where(:user_id => another_user.id).count.should == 1
      end
    end
  end

  describe 'set reminder to idea' do
    before do
      @user = FactoryGirl.create :user, :ideas => []
    end

    it 'should create a new reminder' do
      user_idea = @user.create_new_idea!(:content => 'ana are mere', :privacy => Privacy::Values[:public])
      reminder_date = Time.now.next_year
      @user.set_reminder_to_idea! user_idea.id, :reminder_date => reminder_date
      user = User.find(@user.id)
      user.ideas.first.reminder_date.should_not be_nil
    end
  end

  describe 'ideas ordered by latest reminder creation date' do
    let :user do
      FactoryGirl.create :simple_user
    end

    it 'should return all the ideas' do
      3.times do
        user.create_new_idea! :content => 'idea', :privacy => Privacy::Values[:public]
      end
      user.ideas_ordered_by_reminder_created_at.size.should == 3
    end

    it 'should be in the right order' do
      idea1 = Idea.create! :content => 'idea', :privacy => Privacy::Values[:public]
      idea2 = Idea.create! :content => 'idea', :privacy => Privacy::Values[:public]
      idea3 = Idea.create! :content => 'idea', :privacy => Privacy::Values[:public]
      user_idea1 = UserIdea.create! :idea_id => idea1.id, :privacy => Privacy::Values[:public],
                                    :reminder_created_at => 2.days.ago,
                                    :user_id => user.id
      user_idea2 = UserIdea.create! :idea_id => idea2.id, :privacy => Privacy::Values[:public],
                                    :reminder_created_at => 1.days.ago,
                                    :user_id => user.id
      user_idea3 = UserIdea.create! :idea_id => idea3.id, :privacy => Privacy::Values[:public],
                                    :reminder_created_at => 3.days.ago,
                                    :user_id => user.id
      ideas = user.ideas_ordered_by_reminder_created_at.entries
      ideas.should == [user_idea2, user_idea1, user_idea3]
    end
  end

  describe 'ideas_from_list_ordered_by_reminder_created_at' do
    let :user do
      FactoryGirl.create :simple_user
    end

    let :idea_list do
      IdeaList.new :user => user, :name => 'idea_list'
    end

    it 'should return all the ideas' do
      3.times do
        user_idea = user.create_new_idea! :content => 'idea',
                                          :privacy => Privacy::Values[:public]
        idea_list.ideas.push user_idea
      end

      2.times do
        user.create_new_idea! :content => 'idea',
                              :privacy => Privacy::Values[:public]
      end
      user.ideas_from_list_ordered_by_reminder_created_at(idea_list).size.should == 3
    end

    it 'should be in the right order' do
      idea1 = Idea.create! :content => 'idea', :privacy => Privacy::Values[:public]
      idea2 = Idea.create! :content => 'idea', :privacy => Privacy::Values[:public]
      idea3 = Idea.create! :content => 'idea', :privacy => Privacy::Values[:public]
      idea4 = Idea.create! :content => 'idea', :privacy => Privacy::Values[:public]
      user_idea1 = UserIdea.create! :idea_id => idea1.id,
                                    :privacy => Privacy::Values[:public],
                                    :reminder_created_at => 2.days.ago,
                                    :user_id => user.id
      user_idea2 = UserIdea.create! :idea_id => idea2.id,
                                    :privacy => Privacy::Values[:public],
                                    :reminder_created_at => 1.days.ago,
                                    :user_id => user.id
      user_idea3 = UserIdea.create! :idea_id => idea3.id,
                                    :privacy => Privacy::Values[:public],
                                    :reminder_created_at => 4.days.ago,
                                    :user_id => user.id
      user_idea4 = UserIdea.create! :idea_id => idea4.id,
                                    :privacy => Privacy::Values[:public],
                                    :reminder_created_at => 3.days.ago,
                                    :user_id => user.id
      idea_list.ideas << user_idea1
      idea_list.ideas << user_idea2
      idea_list.ideas << user_idea4
      idea_list.save!
      ideas = user.ideas_from_list_ordered_by_reminder_created_at(idea_list).entries
      ideas.should == [user_idea2, user_idea1, user_idea4]
    end
  end

  describe 'idea_list_with_id' do
    let :user do
      FactoryGirl.create :simple_user
    end

    let :idea_list do
      FactoryGirl.create :idea_list, :user => user, :name => 'idea_list'
    end

    it 'should not be nil' do
      user.idea_list_with_id(idea_list.id).should_not be_nil
    end

    it 'should have the right name' do
      user.idea_list_with_id(idea_list.id).name.should == 'idea_list'
    end

    it 'should return nil if the id does not exist' do
      user.idea_list_with_id(user.id).should be_nil
    end
  end

  describe 'user idea for idea' do
    let :user do
      FactoryGirl.create :simple_user
    end

    before do
      @reminder_date = Date.new 2020
      @user_idea = user.create_new_idea!(:content => 'ana are mere',
                                               :privacy => Privacy::Values[:public],
                                               :reminder_date => @reminder_date)
      @other_idea = FactoryGirl.create :idea
    end

    it 'should not be nil' do
      user.user_idea_for_idea(@user_idea.idea).should_not be_nil
    end

    it 'should have the right name' do
      user.user_idea_for_idea(@user_idea.idea).reminder_date.should == @reminder_date
    end

    it 'should return nil if the id does not exist' do
      user.user_idea_for_idea(@other_idea).should be_nil
    end
  end

  describe 'create idea list' do
    let :user do
      FactoryGirl.create :unique_user
    end

    describe 'success' do
      before do
        user.create_idea_list 'the list'
      end

      it 'should create a new idea list' do
        user.idea_lists.should_not be_empty
      end

      it 'should have the right name' do
        user.idea_lists.first.name.should == 'the list'
      end

      it 'should increment the idea_lists_count' do
        user.idea_lists_count.should == 1
      end
    end

    describe 'failure' do
      before do
        user.create_idea_list ''
      end

      it 'should not create a new idea list' do
        user1 = User.find(user.id)
        user1.idea_lists.should be_empty
      end

      it 'should not increment the idea_lists_count' do
        user.idea_lists_count.should == 0
      end
    end
  end

  describe 'remove idea list' do
    let :user do
      FactoryGirl.create :unique_user
    end

    before do
      @idea_list = user.create_idea_list 'the list'
    end

    describe 'success' do

      before do
        user.remove_idea_list @idea_list
      end

      it 'should remove the idea list' do
        user.idea_lists.should be_empty
      end

      it 'should decrement idea_list_count' do
        user.idea_lists_count.should == 0
      end
    end

    describe 'failure' do

      let :other_idea_list do
        FactoryGirl.create :idea_list
      end

      it 'should return false' do
        user.remove_idea_list(other_idea_list).should == false
      end

      it 'should not remove the idea list' do
        user.remove_idea_list other_idea_list
        user.idea_lists.should_not be_empty
      end

      it 'should not decrement idea_list_count' do
        user.remove_idea_list other_idea_list
        user.idea_lists_count.should == 1
      end
    end
  end

  describe 'find by password reset code' do
    let :password_reset_code do
      '12345'
    end

    before do
      FactoryGirl.create(:unique_user, :password_reset_code => password_reset_code)
    end

    it 'should find the user' do
      User.find_by_password_reset_code(password_reset_code).should_not be_nil
    end
  end

  describe 'find by email' do
    let :email do
      'dan@yahoo.com'
    end

    before do
      FactoryGirl.create :unique_user, :email => email
    end

    it 'should find the user' do
      User.find_by_email(email).should_not be_nil
    end

  end

  describe 'has idea' do
    before do
      @user = FactoryGirl.create :user, :ideas => []
      @user_idea = @user.create_new_idea!(:content => 'ana are mere', :privacy => Privacy::Values[:public])
      @other_idea = FactoryGirl.create :idea
    end

    it 'should have the correct idea' do
      @user.has_idea?(@user_idea.idea).should == true
    end

    it 'should not return true for other ideas' do
      @user.has_idea?(@other_idea).should == false
    end
  end

  describe 'has user idea' do
    before do
      @user = FactoryGirl.create :user, :ideas => []
      @user_idea = @user.create_new_idea!(:content => 'ana are mere', :privacy => Privacy::Values[:public])
      @other_user_idea = FactoryGirl.create :user_idea
    end

    it 'should have the correct idea' do
      @user.has_user_idea?(@user_idea).should == true
    end

    it 'should not return true for other ideas' do
      @user.has_user_idea?(@other_user_idea).should == false
    end
  end

  describe '#push_follower' do
    before do
      @user = FactoryGirl.create :unique_user
      @other_user = FactoryGirl.create :unique_user
      @user.push_follower(@other_user)
    end

    it 'should increment the followers_count' do
      @user.followers_count.should == 1
    end

    it 'should include the other_user as a follower' do
      @user.followers.should include(@other_user)
    end

    it 'should not increment the followers_count two times for the same follower' do
      @user.push_follower(@other_user)
      @user.followers_count.should == 1
    end
  end

  describe '#push_following' do
    before do
      @user = FactoryGirl.create :unique_user
      @other_user = FactoryGirl.create :unique_user
      @user.push_following(@other_user)
    end

    it 'should increment the following_count' do
      @user.following_count.should == 1
    end

    it 'should include the other_user as a following' do
      @user.following.should include(@other_user)
    end

    it 'should not increment the following_count two times for the same following user' do
      @user.push_following(@other_user)
      @user.following_count.should == 1
    end
  end

end
