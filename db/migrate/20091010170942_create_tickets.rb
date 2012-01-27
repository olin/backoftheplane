class CreateTickets < ActiveRecord::Migration
  def self.up
    create_table :tickets do |t|
      t.timestamps
      t.integer :flight_id
      t.integer :user_id
      t.text :bio
      t.text :interests
      t.string :seat
    end
  end

  def self.down
    drop_table :tickets
  end
end
