require 'digest/sha1'

class AccountController < ApplicationController
  before_filter :authorize, :except => [:login, :signup, :signup_backend, :login_backend, :logout]
    
  def signup
    if session[:user_id]
      redirect_to :controller => :home
    end
  end
  
  def signup_backend
    #hash the password using SHA1
    
    sha_passwd = Digest::SHA1.hexdigest(params[:account][:password])

    #see if password and password confirm match
    if params[:account][:password] != params[:account][:password_confirm]
      flash[:error] = "Passwords don't match."
      redirect_to :action => :signup
      return
    end

    #Create the actual user account
    @user = User.new(:username => params[:account][:username],
                    :email => params[:account][:email].to_s.downcase,
                    :password_hashed => sha_passwd,
                    :last_login_at => Time.now)

    #Save user to the database
    if @user.save
      #If it worked, log them in and send them to the next step
      flash[:success] = "Hey " + @user.username + "!"
      redirect_to :action => :login_backend, :account => {:email => params[:account][:email], :password => params[:account][:password]}
    else
      #If it didn't work, send them to sign up again
      flash[:error] = @user.errors.full_messages.join('<br />')
      redirect_to :action => :signup, :user => @user
    end
  end
  
  #This is the part that does the actual logging in
  def login_backend
    email = params[:account][:email].to_s.downcase
    sha_password = Digest::SHA1.hexdigest(params[:account][:password])

    #Find the first user who meets these conditions
    user = User.find :first, :conditions => ["email=? and password_hashed=?", email, sha_password]

    if user
      if user.banned
        flash[:error] = "This account has been banned."
        redirect_to :controller => :home, :action => :index
      end
      
      #Establish Session
      session[:user_id] = user.id
      session[:user_email] = user.email
      session[:user_username] = user.username
      session[:previous_login_at] = user.last_login_at
      session[:admin] = user.admin
      #Update info
      user.last_login_at = Time.now
      user.login_count += 1
      user.save
      new_tickets = 0
      for ticket in user.tickets
        new_tickets += Ticket.find(:all,
                                   :conditions => [
                                     "flight_id = :flight_id AND created_at > :previous_login_at AND user_id != :user_id",
                                     {:flight_id => ticket.flight.id, :previous_login_at => session[:previous_login_at], :user_id => session[:user_id]}]
                                     ).length
      end

      #Set up flashes
      if (session[:previous_login_at] > (Time.now - 100))
        flash[:success] = "Hey " + user.username + ", welcome to Back of the Plane! Why don't you add some interests and a short biography?"
      else
        if new_tickets > 0
          flash[:notice] = new_tickets.to_s + " new people on your flights since last login!"
        else
          flash[:success] = "Welcome back, " + user.username + "!"
        end
      end
            
      #Redirect!
      if session[:pending_ticket]
        redirect_to :controller => :ticket, :action => :add_ticket
      else
        if (session[:previous_login_at] > (Time.now - 100))
          redirect_to :action => :edit
        else
          redirect_to :controller => :home, :action => :index
        end
      end
    else
      #If email/password are not in our database, get mad
      flash[:error] = "Incorrect username or password."
      redirect_to :controller => :account, :action => :login
    end
  end
  
  def logout
    #Blank out all their info when they log out
    session[:user_id] = nil
    session[:user_email] = nil
    session[:user_username] = nil
    session[:admin] = nil
    flash[:notice] = "You are now logged out."
    redirect_to :controller => :home, :action => :index
  end

  #Edit users
  def edit
    authorize
    
    @user = User.find_by_id(session[:user_id])
    if params[:account]
      @user.email = params[:account][:email];
      @user.username = params[:account][:username];
      @user.default_bio = params[:account][:default_bio];
      @user.default_interests = params[:account][:default_interests];
      if params[:account][:password] != ""
        if params[:account][:password] != params[:account][:password_confirm]
          flash[:error] = "Passwords don't match"
          redirect_to :action => :edit
          return
        end
        @user.password = Digest::SHA1.hexdigest(params[:account][:password])
      end
      if @user.save
        flash[:notice] = "Your settings are updated!"
        redirect_to :controller => :home, :action => :index
      else
        redirect_to :action => :edit
      end               
    end
  end
  
  protected
  def authorize
    unless User.find_by_id(session[:user_id]) 
      flash[:notice] = "Please log in" 
      redirect_to :controller => :account, :action => :login 
    end
  end
end
