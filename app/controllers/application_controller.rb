# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  def get_busy_times(calendar_ids, min_date, max_date, access_token)
    form_data = {
      "items" => calendar_ids.map{ |x| {:id => x} },
      "timeMin" => "#{min_date.year}-#{min_date.month}-#{min_date.day}T00:00:00+00:00",
      "timeMax" => "#{max_date.year}-#{max_date.month}-#{max_date.day}T23:59:00+00:00"   
    }
    uri = URI.parse("https://www.googleapis.com/calendar/v3/freeBusy?access_token=#{access_token}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true 
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = form_data.to_json
    request['Content-Type'] = 'application/json'
    response = http.request(request)
    response_json = JSON.parse(response.body) 
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
    form_data = {
      "client_id" => "621760050683-as0aceoats9oouvtbqbsvk55aobu3gt6.apps.googleusercontent.com",
      "client_secret" => "nPxCjK7KxzIUZGFojl4qiQkd",
      "refresh_token" => refresh_token,
      "grant_type" => "refresh_token"
    }
    uri = URI.parse("https://www.googleapis.com/oauth2/v4/token")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true 
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(form_data)
    response = http.request(request)
    response_json = JSON.parse(response.body)
    access_token = response_json["access_token"]
    access_token
  end
end