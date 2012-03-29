require 'spec_helper'

describe User do
  describe 'profile association' do
    it 'should have a profile attribute' do
      user = User.new
      user.should respond_to(:profile)
    end
  end

  describe 'following association' do
    let :user do
      FactoryGirl.build :simple_user
    end

    let :other_user do
      FactoryGirl.build :simple_user
    end

    it 'should have a following association' do
      user.should respond_to :following
    end

    it 'should have the right following user' do
      user.following.push other_user
      user.following.first.should == other_user
    end
  end

  describe 'followers association' do
    let :user do
      FactoryGirl.build :simple_user
    end

    let :other_user do
      FactoryGirl.build :simple_user
    end

    it 'should have a followers association' do
      user.should respond_to :followers
    end

    it 'should have the right follower user' do
      user.followers.push other_user
      user.followers.first.should == other_user
    end
  end
end