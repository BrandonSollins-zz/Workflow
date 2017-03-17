class AddTimesAndMusiciansToBooking < ActiveRecord::Migration
  def self.up
    add_column :bookings, :times_and_musicians, :text
    add_column :bookings, :times_and_musicians_attempted, :text
    add_column :bookings, :times_and_musicians_attempts, :text
  end

  def self.down
    remove_column :bookings, :times_and_musicians
    remove_column :bookings, :times_and_musicians_attempted
    remove_column :bookings, :times_and_musicians_attempts
  end
end