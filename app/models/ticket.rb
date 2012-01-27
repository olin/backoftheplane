class Ticket < ActiveRecord::Base
  belongs_to :user
  belongs_to :flight
  validates_uniqueness_of :ticket=> [:user, :flight]
end
