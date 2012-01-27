module TicketHelper
  
  def users_added_to_flight_since_previous_login(flight_id)
    Ticket.find(:all,
                :conditions => [
                  "flight_id = :flight_id AND created_at > :previous_login_at AND user_id != :user_id",
                  {:flight_id => flight_id, :previous_login_at => session[:previous_login_at], :user_id => session[:user_id]}]
                ).length
  end
  
  def users_on_flight(flight_id)
    Ticket.find(:all,
                :conditions => [
                  "flight_id = :flight_id",
                  {:flight_id => flight_id}]
                ).count
  end
  
end