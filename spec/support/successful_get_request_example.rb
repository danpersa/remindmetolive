shared_examples_for "successful get request" do

  before(:each) do
    action
  end

  it "should be successful" do
    response.should be_success
  end
  
  it "should have the right title" do
    #page.should have_selector 'title', :text => @title
  end
end