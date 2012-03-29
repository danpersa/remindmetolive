require 'spec_helper'

describe Profile do
  describe "creation" do

    let(:profile) do
      FactoryGirl.build(:profile)
    end

    let(:user) do
      FactoryGirl.build(:simple_user)
    end

    it "should create a new instance given valid attributes" do
      user.profile = profile
      profile.save.should == true
    end
  end

  describe "global validations" do
    context "empty profile" do

      let(:profile) do
        Profile.new
      end

      let(:user) do
        FactoryGirl.create(:simple_user)
      end

      it "should not be rejected" do
        user.profile = profile
        user.save.should == true
      end
    end
  end

  describe "field validations" do
    describe "name field" do
      context "too long" do
        let(:profile) do
          FactoryGirl.build :profile, :name => 'a' * 51
        end

        it "should be shorter than 50 characters" do
          profile.valid?
          profile.errors[:name].should == [ "is too long (maximum is 50 characters)" ]
        end
      end
    end

    describe "email field" do
      context "too long" do
        let(:profile) do
          FactoryGirl.build :profile, :email => 'a' * 255 + '@yahoo.com'
        end

        it "should be shorter than 255 characters" do
          profile.valid?
          profile.errors[:email].should == [ "is too long (maximum is 255 characters)" ]
        end
      end

      context "invalid" do
        it "should be rejected" do
          addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
          addresses.each do |address|
            invalid_email_profile = FactoryGirl.build(:profile, :email => address)
            invalid_email_profile.should_not be_valid
          end
        end
      end

      describe "location field" do
        context "too long" do
          let(:profile) do
            FactoryGirl.build :profile, :location => 'a' * 101
          end

          it "should be shorter than 100 characters" do
            profile.valid?
            profile.errors[:location].should == [ "is too long (maximum is 100 characters)" ]
          end
        end
      end

      describe "website field" do
        context "too long" do
          let(:profile) do
            FactoryGirl.build :profile, :website => 'a' * 101
          end

          it "should be shorter than 100 characters" do
            profile.valid?
            profile.errors[:website].should == [ "is too long (maximum is 100 characters)" ]
          end
        end
      end
    end
  end

  describe "user association" do
    before do
      @user = FactoryGirl.create(:simple_user)
      @profile = FactoryGirl.build(:profile)
      @profile.user = @user
    end

    it "should have a user attribute" do
      @profile.should respond_to(:user)
    end

    it "should have the right associated user" do
      @profile.save!
      @user.reload
      @user.profile.should_not be_nil
      @user.profile.should == @profile
    end
  end

  describe "empty method" do
    it "should have an empty method" do
      profile = FactoryGirl.build(:profile)
      profile.should respond_to('empty_profile?')
    end

    it "should be empty" do
      profile = FactoryGirl.build(:profile, :email => "", :name => "",
        :location => "", :website => "")
      profile.should be_empty_profile
    end

    it "should not be empty" do
      profile = FactoryGirl.build(:profile)
      profile.should_not be_empty_profile
    end
  end
end
