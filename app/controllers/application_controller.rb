class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def get_busy_times(calendar_ids, min_date, max_date, access_token)
    http_client = HTTPClient.new
    body = {
      "items": calendar_ids.map{ |x| {:id => x} },
      "timeMin": "#{min_date.year}-#{min_date.month}-#{min_date.day}T00:00:00+00:00",
      "timeMax": "#{max_date.year}-#{max_date.month}-#{max_date.day}T23:59:00+00:00"
    }.to_json
    response = http_client.post("https://www.googleapis.com/calendar/v3/freeBusy?access_token=#{access_token}", body, { "Content-Type": "application/json" })
    response_json = JSON.parse(response.body)
    puts "woohoo #{response_json}"
    busy_times = []
    response_json["calendars"].keys.each do |calendar|
      unless response_json["calendars"][calendar]["busy"].blank?
        response_json["calendars"][calendar]["busy"].each do |busy|
          busy_times.push([busy["start"], busy["end"]])
        end
      end
    end
    busy_times
  end

  def get_access_token(refresh_token)
    http_client = HTTPClient.new
    body = {
      "client_id": "621760050683-as0aceoats9oouvtbqbsvk55aobu3gt6.apps.googleusercontent.com",
      "client_secret": "nPxCjK7KxzIUZGFojl4qiQkd",
      "refresh_token": refresh_token,
      "grant_type": "refresh_token"
    }
    response = http_client.post("https://www.googleapis.com/oauth2/v4/token", body)
    response_json = JSON.parse(response.body)
    response_json["access_token"]
  end
end
