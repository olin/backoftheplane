class AccountMailer < ActionMailer::Base
  def welcome(user)
     subject    'Welcome to Back of the Plane!'
     recipients user.email 
     from       'backoftheplane@gmail.com'
     sent_on    Time.now

     body       :user => user
   end  

end
