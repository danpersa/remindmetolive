shared_examples_for "redirect with flash" do

  before(:each) do
    action
  end

  it "should redirect to path" do
    response.should redirect_to(@path)
  end
  
  it "should have a notification flash message" do
    flash[@notification].should =~ @message
  end
end


shared_examples_for "deny access unless signed in" do

  it_should_behave_like "redirect with flash" do
    before(:each) do
      request_action
    end
    let(:action) do
      @notification = :notice
      @message = /sign in/i
      @path = signin_path
    end
  end
  
end