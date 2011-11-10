class UsersController < ApplicationController
  before_filter :authentificate, :only => [:edit, :update]

  def new
     @title = "Sign Up"
     @user = User.new
  end

  def show
    @user = User.find(params[:id])
    @title = @user.name
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      redirect_to @user, :flash => { :success => "Welcome to the sample app"}
    else
      @title = "Sign up"
      render 'new'
    end
  end 
  
  def edit
    @user = User.find(params[:id])
    @title = "Edit user"
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to @user, :flash => { :success => "Profile updated"}
    else
      @title = "Edit user"
      render 'edit'
    end
  end
    
  private
    def authentificate 
      deny_access unless signed_in?
    end
    
    def deny_access
      redirect_to signin_path, :notice =>  "Please sign in to access this page."
    end  
end
