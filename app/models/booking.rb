class Booking < ActiveRecord::Base
  serialize :available_musicians, Hash
  serialize :available_times, Array
  serialize :required_instruments, Array
  serialize :chosen_musicians, Array
  serialize :times_and_musicians, Array
  serialize :times_and_musicians_attempted, Array
  serialize :times_and_musicians_attempts, Array
end