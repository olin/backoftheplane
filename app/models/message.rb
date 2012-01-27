class Message < ActiveRecord::Base
  belongs_to :user, :foreign_key => "user_to_id"
  belongs_to :user, :foreign_key => "user_from_id"
  belongs_to :ticket
  
  validates_presence_of :subject
  validates_presence_of :message
end
