require 'spec_helper'

describe SessionsController do
  
  render_views
  
  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
    
    it "should have right title" do
      get :new
      response.should have_selector("title", :content => "Sign In")
    end
    
  end
  
  describe "POST 'create'" do
    describe "failure" do
      
      before(:each) do
        @attr = {:email => "", :password => ""}
      end
      
      it "should re-render the new page" do
        post :create, :session => @attr
        response.should render_template('new')
      end
      
      it "should have right title" do
        post :create, :session => @attr
        response.should have_selector(:title, :content => "Sign In")
      end
      
      it "should have an error messsage" do
        post :create, :session => @attr
        flash.now[:error].should =~ /invalid/i
      end
      
    end
  end

end
