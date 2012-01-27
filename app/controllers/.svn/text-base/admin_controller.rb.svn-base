class AdminController < ApplicationController
  before_filter :authorize
  
  def index  
  end
  
  def metrics
  end
  
  def all_users
    if params[:order]
      @order = params[:order]
      if params[:asc] == "asc"
        @order += " ASC"
      else
        @order += " DESC"
      end
    else
      @order = "username ASC"
    end
    @users = User.paginate(:page => params[:page], :per_page => 100, :order => @order)
  end
  
  def edit_user
    @user = User.find_by_id(params[:id])
    
    if params[:admin]
      @user.email = params[:admin][:email];
      @user.username = params[:admin][:username];
      @user.default_bio = params[:admin][:default_bio];
      @user.default_interests = params[:admin][:default_interests];
      @user.admin = params[:admin][:admin]
      @user.banned = params[:admin][:banned]
      if params[:admin][:password] != ""
        if params[:admin][:password] != params[:admin][:password_confirm]
          flash[:error] = "Passwords don't match"
          redirect_to :action => :edit_user
          return
        end
        @user.password = Digest::SHA1.hexdigest(params[:admin][:password])
      end
      if @user.save
        flash[:notice] = "User edited!"
        redirect_to :controller => :admin, :action => :all_users
      else
        flash[:error] = "User edit failed."
        redirect_to :action => :edit_user
      end               
    end
  end
  
  def all_flights
    if params[:order]
      @order = params[:order]
      if params[:asc] == "asc"
        @order += " ASC"
      else
        @order += " DESC"
      end
    else
      @order = "id ASC"
    end
    @flights = Flight.paginate(:page => params[:page], :per_page => 100, :order => @order)
  end
  
  def edit_flight
    @flight = Flight.find_by_id(params[:id])
        
    if params[:admin]
      if params[:admin][:delete]
        if @flight.destroy
          flash[:notice] = "Flight deleted!"
          redirect_to :controller => :admin, :action => :all_flights 
          return
        else
          flash[:error] = "Flight delete failed."
          redirect_to :controller => :admin, :action => :edit_flight, :id => :id
          return
        end
      end
      
      @flight.flight_date = params[:admin][:flight_date]
      @flight.flight_name = params[:admin][:flight_name]
      @flight.airline = params[:admin][:airline]
      @flight.airport_code_to = params[:admin][:airport_code_to]
      @flight.airport_code_from = params[:admin][:airport_code_from]
      if @flight.save
        flash[:notice] = "Flight edited!"
        redirect_to :controller => :admin, :action => :all_flights 
      else
        flash[:error] = "Flight edit failed."
        redirect_to :action => :edit_flight
      end               
    end
  end
  
  protected
  def authorize 
    unless session[:user_id] and User.find_by_id(session[:user_id]).admin
      redirect_to :controller => :home
    end 
  end
end