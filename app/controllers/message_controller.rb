class MessageController < ApplicationController
  
  def new
    @user_to_username = params[:to_username]
    @subject = params[:subject]
  end
  
  def new_backend
    user_to_username = params[:message][:user_to_username]
    subject = params[:message][:subject]
    message_body = params[:message][:message]
    
    user = User.find :first, :conditions => ["username=?", user_to_username]
    unless user
      flash[:error] = "User doesn't exist."
      redirect_to :action => :new
      return
    end
    
    @message = Message.new(:user_from_id => session[:user_id],
                           :user_to_id => user.id,
                           :subject => subject,
                           :message => message_body)

    if @message.save
      flash[:success] = "Message sent!"
      redirect_to :action => :inbox
    else
      flash[:error] = "Message failed to send."
      redirect_to :action => :inbox
    end
    
  end
  
  def read
    @message = Message.find(:first, :conditions => ["id=?", params[:id]])
    unless @message.user_to_id == session[:user_id] or @message.user_from_id == session[:user_id]
      flash[:error] = "This isn't to you."
      redirect_to :action => :inbox
    end
    if @message.user_to_id == session[:user_id]
      @message["to_from"] = "from"
      # FIXME: This ought to be FK'd into a message anyway.
      @message["other_user"] = User.find(:first, :conditions => ["id=?", @message.user_from_id])
      @message.read_message = true
      @message.save
    else
      @message["to_from"] = "to"
      # FIXME: This ought to be FK'd into a message anyway.
      @message["other_user"] = User.find(:first, :conditions => ["id=?", @message.user_to_id])
    end
  end
  
  def delete
  	@message = Message.find(:first, :conditions => ["id=?", params[:id]])
    
    #Now with more catching of edge cases (like if you message yourself and then want to delete both)
	  if @message.user_to_id == session[:user_id]
		  @message.deleted_by_recipient = true
  	end
    
    if @message.user_from_id == session[:user_id]
	  	@message.deleted_by_sender = true
  	end
    
    if @message.save
      flash[:success] = "Message deleted"
    else
      flash[:error] = "Delete failed"
    end
    
    redirect_to :action => :inbox
  end
  
  def inbox
    @raw_messages = Message.find(:all, :order => "created_at DESC", :conditions => ["user_to_id=? or user_from_id=?", session[:user_id], session[:user_id]])

    @messages = Array.new

    for message in @raw_messages
      if message.user_to_id == session[:user_id] and not message.deleted_by_recipient
        message["to_from"] = "from"
        # FIXME: This ought to be FK'd into a message anyway.
        message["other_user"] = User.find(:first, :conditions => ["id=?", message.user_from_id])
        @messages << message
      end
      
      if message.user_from_id == session[:user_id] and not message.deleted_by_sender
        message["to_from"] = "to"
        # FIXME: This ought to be FK'd into a message anyway.
        message["other_user"] = User.find(:first, :conditions => ["id=?", message.user_to_id])
        @messages << message
      end
    end
    
  end
  
end
