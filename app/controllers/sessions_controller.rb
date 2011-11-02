class SessionsController < ApplicationController
  def new
    @title = "Sign In"
  end
  
  def create
    user = User.authentificate( params[:session][:email], 
                                params[:session][:password])
    if user.nil?
      flash.now[:error] = "Invalid combination email/password"
      @title = "Sign In"
      render 'new'
    else
      # Hande success  
    end
    
  end
  
  def destroy
    
  end

end
