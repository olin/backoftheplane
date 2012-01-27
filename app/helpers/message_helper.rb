module MessageHelper

	def unread_message_count_num
		messages = Message.find(:all, :conditions => ["user_to_id=? and read_message=?", session[:user_id], false])
		if messages.length > 0
			messages.length
		else
			0
		end
	end
	
	def unread_message_count
		messages = Message.find(:all, :conditions => ["user_to_id=? and read_message=?", session[:user_id], false])
		if messages.length > 0
			" (" +messages.length.to_s()+")"
		else
			""
		end
	end

end