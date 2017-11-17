require "clockwork"
require "./config/boot"
require "./config/environment"

module Clockwork
  every(10.seconds, "check_messaged_musicians") do
    BookingsController.new.check_messaged_musicians
  end
end
