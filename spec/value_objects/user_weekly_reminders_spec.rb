require 'spec_helper'

describe UserWeeklyReminders do

  before do
    @user = FactoryGirl.create :simple_user
    @user_idea_current_week1 = FactoryGirl.create :user_idea, user: @user, reminder_date: DateTime.new(2013, 7, 25)
    @user_idea_current_week2 = FactoryGirl.create :user_idea, user: @user, reminder_date: DateTime.new(2013, 7, 28)
    @user_idea1 = FactoryGirl.create :user_idea, user: @user, reminder_date: DateTime.new(2013, 7, 29)
    @user_idea2 = FactoryGirl.create :user_idea, user: @user, reminder_date: DateTime.new(2013, 7, 31)
    @user_idea3 = FactoryGirl.create :user_idea, user: @user, reminder_date: DateTime.new(2013, 8, 4)
    @user_idea_two_weeks_ahead1 = FactoryGirl.create :user_idea, user: @user, reminder_date: DateTime.new(2013, 8, 5)
    @user_idea_two_weeks_ahead2 = FactoryGirl.create :user_idea, user: @user, reminder_date: DateTime.new(2013, 8, 8)
  end

  describe '#reminders' do
    before do
      weekly_user_reminders = UserWeeklyReminders.new @user, DateTime.new(2013, 7, 23)
      @user_ideas = weekly_user_reminders.reminders
    end

    it 'should have the right size' do
      @user_ideas.size.should == 3
    end

    it 'should contain the reminders from the next week' do
      @user_ideas.should include(@user_idea1)
      @user_ideas.should include(@user_idea2)
      @user_ideas.should include(@user_idea3)
    end

    it 'should not contain the user ideas from the current week' do
      @user_ideas.should_not include(@user_idea_current_week1)
      @user_ideas.should_not include(@user_idea_current_week2)
    end

    it 'should not contain the user idea form two weeks ahead' do
      @user_ideas.should_not include(@user_idea_two_weeks_ahead1)
      @user_ideas.should_not include(@user_idea_two_weeks_ahead2)
    end
  end
end