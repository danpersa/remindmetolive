require 'spec_helper'

describe DoneIdeasController do
  render_views

  describe "POST 'create'" do

    before(:each) do
      @user = FactoryGirl.create(:unique_user)
      @idea = FactoryGirl.create(:simple_idea, :owned_by => @user)
      test_sign_in(@user)
    end

    describe "success" do
       
      it "should create a done idea" do
        post :create, :id => @idea.id
        @idea.reload
        @idea.users_marked_the_idea_done_count.should == 1
        @idea.users_marked_the_idea_done.should include @user
      end
    end
  end

  describe "DELETE 'destroy'" do

    before(:each) do
      @user = FactoryGirl.create(:unique_user)
      @idea = FactoryGirl.create(:simple_idea, :owned_by => @user,
                                 :users_marked_the_idea_done_count => 1,
                                 :users_marked_the_idea_done => [@user])
      @idea.users_marked_the_idea_done << @user
      test_sign_in(@user)
    end

    describe "success" do

      it "should destroy a done idea" do
      	delete :destroy, :id => @idea.id
        @idea.reload
        @idea.users_marked_the_idea_done_count.should == 0
        @idea.users_marked_the_idea_done.should_not include @user
      end
    end
  end
end
