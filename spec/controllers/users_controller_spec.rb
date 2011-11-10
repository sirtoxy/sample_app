require 'spec_helper'

describe UsersController do

  render_views

  describe "GET 'show'" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end
    
    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end
    
    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector(:title, :content => @user.name)
    end
    
    it "should have the right name" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.name)
    end
    
    it "should have a profile image" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end
    
    it "should have the right URL" do
        get :show, :id => @user
        response.should have_selector("td>a", :content => user_path(@user),
                                              :href => user_path(@user)     )
    end
    
  end

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
    
    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "Sign Up")
    end
    
  end

  describe "POST 'create'" do
    
    describe "failure" do
      before(:each) do
        @attr = { :name => "", :email => "", :password => "", :password_confirmation => ""}
      end
      
      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector(:title, :content => "Sign up")
        
      end
      
      it "should render the 'new' page" do
         post :create, :user => @attr
         response.should render_template('new')
      end
      
      it "should not create an user" do
        lambda do
         post :create, :user => @attr
        end.should_not change(User, :count)
      end  
    end
    
    describe "Success" do
      before(:each) do
        @attr = {:name => "New User", :email => "newuser@g.com", 
                :password => "foobar", :password_confirmation => "foobar"}  
      end
      
      it "should create user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end
      
      it "should redirect to user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end
      
      it "should have a welcome message" do
         post :create, :user => @attr
         flash[:success].should =~ /welcome to the sample app/i
      end
      
      it "shpould sign user in" do
         post :create, :user => @attr
         controller.should be_signed_in
      end
      
    end
    
  end
  
  describe "GET 'edit'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end
    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector("title", :content => "Edit user")
    end
    it "should have a link to change the gravatar" do
      get :edit, :id => @user
      response.should have_selector("a", :href => 'http://gravatar.com/emails',
                                        :content => 'change')
    end  
  end

  describe "PUT 'update'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    describe "failure" do
      before(:each) do
         @attr = {:name => "", :email => "", 
                :password => "", :password_confirmation => ""}
      end
      it "should render the edit page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end 
      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector('title', :content => "Edit user")
      end 
    end
    
    describe "success" do
      before(:each) do
         @attr = {:name => "New Name", :email => "name@name.com", 
                :password => "barbaz", :password_confirmation => "barbaz"}
      end
      
      it "should change the users attributes" do
        put :update, :id => @user, :user => @attr
        user = assigns(:user)
        @user.reload
        @user.name.should == user.name
        @user.email.should == user.email
        @user.encrypted_password.should == user.encrypted_password
      end
      
      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end  
    end
    
  end


  describe "authentification edit/update user actions" do
    before(:each) do
      @user = Factory(:user)
    end
    it "should deny access to 'edit'" do
      get :edit, :id => @user
      response.should redirect_to(signin_path)
      flash[:notice].should =~ /sign in/i
    end
    
    it "should deny access to 'update'" do
      get :update, :id => @user, :user => {}
      response.should redirect_to(signin_path)
      flash[:notice].should =~ /sign in/i
    end
  end

end
