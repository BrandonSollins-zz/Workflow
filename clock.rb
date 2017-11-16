require "clockwork"

module Clockwork
  every(10.seconds, "test job") do
    puts "woohoo the clock works! #{Time.now}"
  end
end
