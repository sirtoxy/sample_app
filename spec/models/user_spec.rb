require 'spec_helper'

describe User do
  
  before(:each) do
    @attr = {
      :name => "Example user", 
      :email => "user@example.com",
      :password => "foobar",
      :password_confirmation => "foobar"
    }  
  end
  
  it "should create a new instance given a valid attribute" do
    User.create!(@attr)  
  end
  
  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid  
  end
  
  it "should require an emai address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end
   
  it "should reject names that are too long" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end
  
  it "should accept valid email adresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
    
  end
  
  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com foo_at_foo.bar.org first.last@foo.]
    addresses.each do |address|
       invalid_email_user = User.new(@attr.merge(:email => address))
       invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject duplicate email addresses" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should reject email addresses identical up to case" do
    upcase_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcase_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end 
  
  describe "passwords" do
    before(:each) do
      @user = User.new(@attr)
    end
    
    it "should have a password attribute" do
      @user.should respond_to(:password)
    end
    
    it "should have a password confirmation attribute" do
      @user.should respond_to(:password_confirmation)
    end
  end
  
  describe "password vaidations" do
    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
      should_not be_valid
    end
    
    it "should require password confirmation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
      should_not be_valid
    end
    
    it "should reject short passwords" do
      short = "a" * 5 
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end
    
    it "should reject long passwords" do
      long = "a" * 51
      hash = @attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
  end
  
  describe "password encryption" do
    
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should have an encrypted password attibute" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should set the encrypted password attribute" do
      @user.encrypted_password.should_not be_blank
    end
    
    it "should have a salt" do
      @user.should respond_to(:salt)
      
    end
    
    describe "has_password? method" do
      
      it "should exist" do
        @user.should respond_to(:has_password?)
      end  
      
      it "should return true if password match" do
        @user.has_password?(@attr[:password]).should be_true
      end
      
      it "should return false if password doesn't match" do
        @user.has_password?("invalid").should be_false
      end
      
      describe "authentificate method" do
        
        it "should exist" do
          User.should respond_to(:authentificate)  
        end
        
        it "should return nil on email/password mismatch" do
          User.authentificate(@attr[:email], "wrongpass").should be_nil
        end
        
        it "should return nil for an email addresses with no user" do
          User.authentificate("bar@foo.com", @attr[:password]).should be_nil  
        end
        
        it "should return user on email/password match" do
          User.authentificate(@attr[:email], @attr[:password]).should == @user  
        end
          
      end
      
    end
  end 
  
  describe "admin attribute" do
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should respond to admin" do
      @user.should respond_to(:admin)  
    end
    
    it "should not be an admin" do
       @user.should_not be_admin
    end
    
    it "should be convertibale to admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
    
  end
  
  describe "microposts associations" do
    before(:each) do
      @user = User.create(@attr)
      @emp1 = Factory(:micropost, :user => @user, :created_at =>  1.day.ago)
      @emp2 = Factory(:micropost, :user => @user, :created_at =>  1.hour.ago)
    end
    it "should have a micropopsts attribute" do
      @user.should respond_to(:microposts)
    end
    
    it "should have the right microposts in the right order" do
      @user.microposts.should == [@emp2, @emp1]
    end
    
    it "should destroy associated micropost" do
      @user.destroy
      [@emp1, @emp2].each do |micropost|
        lambda do
          Micropost.find(micropost)
        end.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
    
  end
  
end




# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean         default(FALSE)
#

