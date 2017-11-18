require "clockwork"
require "./config/boot"
require "./config/environment"
require "rails"

module Clockwork
  configure do |config|
    log_path = Rails.env == "production" ? "/var/www/html/workflow/Workflow/log/clockwork.log" : STDOUT
    config[:logger] = Logger.new(log_path)
  end

  every(10.seconds, "check_messaged_musicians") do
    BookingsController.new.check_messaged_musicians
  end

end
