class TicketController < ApplicationController

  def flight
    if @flight = Flight.find(params[:id])
      if session[:user_id]
        @user = User.find(session[:user_id])
        @ticket = Ticket.find_by_user_id_and_flight_id(session[:user_id], @flight.id)
        @tickets = Ticket.find_all_by_flight_id(@flight.id, :include => [:user])
        @interests = @tickets.collect{|ticket| ticket.interests.to_s.downcase}.join(", ").split(/, /)
        @interests_hash = Hash.new
        
        for interest in @interests
          if @interests_hash.has_key?(interest)==false
            @interests_hash[interest]=0
          end
          @interests_hash[interest]+=1
        end
        
        @interests_people_hash=Hash.new
        for ticket in @tickets
         interests_person=ticket.interests.to_s.split(/, /)
          for interest in interests_person
            if @interests_people_hash.has_key?(interest.downcase)==false
              @interests_people_hash[interest.downcase]=Array.new
            end
            @interests_people_hash[interest.downcase]<<ticket.user.username
            logger.info(@interests_people_hash[interest.downcase].inspect)
          end
        end
        
        for key,value in @interests_people_hash
         @interests_people_hash[key] = value.uniq
       end
       logger.info(@interests_people_hash.inspect)
        
        @interests = @interests.uniq
        @interests_hash=@interests_hash.sort {|a,b| a[1]<=>b[1]}.reverse
        for interest in @interests
          #@interests_people[interest] = 
        end
      end
    else
      redirect_to :controller => :home, :action => :index
    end
  end

  def add_ticket
    if session[:pending_ticket]
      ticket_flight = session[:pending_ticket][:flight]
      ticket_interests = session[:pending_ticket][:interests]
      ticket_bio = session[:pending_ticket][:bio]
      ticket_seat = session[:pending_ticket][:seat]
    end
    if params[:ticket]
      ticket_flight = params[:id]
      ticket_interests = params[:ticket][:interests]
      ticket_bio = params[:ticket][:bio]
      ticket_seat = params[:ticket][:seat]
    end
    if session[:user_id]
      if flight = Flight.find(ticket_flight)
        user = User.find(session[:user_id])
        if ticket_interests.to_s == ""  
          ticket_interests = user.default_interests
        end
        if ticket_bio.to_s == ""
          ticket_bio = user.default_bio
        end
        if not Ticket.find(:first, :conditions => ["user_id=? and flight_id=?", session[:user_id], flight.id])
          ticket = Ticket.new(:user_id => session[:user_id], 
                              :flight_id => flight.id, 
                              :bio => ticket_bio,
                              :interests => ticket_interests,
                              :seat => ticket_seat)
          ticket.save
        end
        session[:pending_ticket] = nil
        flash[:success] = "Added to flight!"
        redirect_to :action => :flight, :id => flight.id
      end
    else
      session[:pending_ticket] = Hash.new
      session[:pending_ticket][:flight] = ticket_flight
      session[:pending_ticket][:interests] = ticket_interests
      session[:pending_ticket][:bio] = ticket_interests
      session[:pending_ticket][:seat] = ticket_seat
      flash[:notice] = "Please sign in or sign up to add yourself to a flight"
      redirect_to :controller => :account, :action => :login
    end
  end
  
  def delete_ticket
    unless params[:id]
      redirect_to :action => :my_flights
    end
    @ticket = Ticket.find_by_id(params[:id])
    if @ticket
      @flight = @ticket.flight
      @ticket.destroy
      flash[:success] = "You have been removed from flight " + @flight.flight_name
      redirect_to :action => :my_flights
    else
      flash[:error] = "We couldn't remove you from flight " + @flight.flight_name
      redirect_to :action => :my_flights
    end
  end
  
  def my_flights
    @user = User.find(session[:user_id])
  end

end
