class CreateBookings < ActiveRecord::Migration
  def self.up
    create_table :bookings do |t|
      t.text :available_musicians
      t.text :available_times
      t.datetime :time
      t.datetime :completed_at
      t.text :required_instruments
      t.text :chosen_musicians

      t.timestamps
    end
  end

  def self.down
    drop_table :bookings
  end
end
