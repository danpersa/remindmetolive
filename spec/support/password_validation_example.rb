shared_examples_for "password validation" do

  before(:each) do
    action
  end

  it "should be valid with a password" do
    @valid_object.should be_valid
  end

  it "should require a password" do
    @valid_object.password = ""
    @valid_object.password_confirmation = ""
    @valid_object.should_not be_valid
    @valid_object.errors[:password].should include "can't be blank"
  end

  it "should require a matching password confirmation" do
    @valid_object.password_confirmation = "invalid"
    @valid_object.should_not be_valid
    @valid_object.errors[:password].should == ["doesn't match confirmation"]
  end

  it "should reject short passwords" do
    short = "a" * 5
    @valid_object.password = short
    @valid_object.password_confirmation = short
    @valid_object.should_not be_valid
    @valid_object.errors[:password].should == ["is too short (minimum is 6 characters)"]
  end

  it "should reject long passwords" do
    long = "a" * 41
    @valid_object.password = long
    @valid_object.password_confirmation = long
    @valid_object.should_not be_valid
    @valid_object.errors[:password].should == ["is too long (maximum is 40 characters)"]
  end
end