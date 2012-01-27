class User < ActiveRecord::Base
  has_many :tickets
  has_many :messages, :foreign_key => "user_to_id"
  has_many :messages, :foreign_key => "user_from_id"
  
  validates_uniqueness_of :username
  validates_uniqueness_of :email
  
  validates_presence_of :username
  validates_presence_of :email
  validates_presence_of :password_hashed
  
  validates_format_of :email,
                      :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                      :message => 'must be valid'
  
  validate :valid_username?
  
  def valid_username?
	  unless username =~ /^[a-zA-Z0-9]*/
	    errors.add(:username, "must be all alphanumeric characters")
    end
  end
    
end
