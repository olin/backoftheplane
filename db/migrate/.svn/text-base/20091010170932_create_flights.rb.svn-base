class CreateFlights < ActiveRecord::Migration
  def self.up
    create_table :flights do |t|
      t.timestamps
      t.string :flight_name #user specified
      t.timestamp :flight_date #user specified
      t.string :airport_code_from #user specified
      t.string :airport_code_to #user specified
      t.string :airline #user specified
      t.string :airline_code
      t.string :airline_name
      t.string :flight_number
      t.timestamp :scheduled_departure
      t.timestamp :scheduled_arrival
      t.string :origin_airport_code
      t.string :origin_airport_name
      t.string :origin_airport_tz
      t.string :destination_airport_code
      t.string :destination_airport_name
      t.string :destination_airport_tz
    end
  end

  def self.down
    drop_table :flights
  end
end
