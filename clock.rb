require "clockwork"
require_relative "./config/boot"
require_relative "./config/environment"
require "rails"

module Clockwork
  configure do |config|
    log_path = Rails.env == "production" ? "/var/www/html/workflow/log/clockwork.log" : STDOUT
    config[:logger] = Logger.new(log_path)
  end

  every(15.minutes, "check_messaged_musicians") do
    BookingsController.new.check_messaged_musicians
  end

end
