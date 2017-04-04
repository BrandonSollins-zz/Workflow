class SignUpController < ApplicationController

  require "net/https"
  require "uri"
  require "json"
  
  def create
    email = params[:email]
    access_token = params[:access_token]
    refresh_token = params[:refresh_token]
    calendar_ids = params[:calendar_ids]
    found_emails = Musician.all(:conditions => { :email => email } ).count 
    if found_emails == 0 && !access_token.blank? && !refresh_token.blank? && !calendar_ids.blank?
      @musician = Musician.new(
        :name => params[:name],
        :email => params[:email],
        :phone_number => params[:phone_number],
        :primary_instrument => params[:primary_instrument],
        :access_token => params[:access_token],
        :refresh_token => params[:refresh_token],
        :calendar_ids => params[:calendar_ids]
      )
      @musician.save!  
      booking = Booking.new
      booking.chosen_musicians = [@musician.id]
      booking.completed_at = Time.now
      booking.save!
    elsif found_emails > 0
      redirect_to :controller => "sign_up", :action => "index", :flash => "Email already exsists. Please sign up with a different email."
    elsif calendar_ids.blank?
      redirect_to :controller => "sign_up", :action => "index", :flash => "Please select at least 1 calendar to track."
    elsif access_token.blank? || refresh_token.blank? 
      redirect_to :controller => "sign_up", :action => "index", :flash => "Error validating email. Please try again."
    end  
  end

  def index
    @musician = Musician.new
    @redirect_uri = "https://custom-tracks.com/workflow/sign-up"
    @client_id = "621760050683-as0aceoats9oouvtbqbsvk55aobu3gt6.apps.googleusercontent.com"
    @client_secret = "nPxCjK7KxzIUZGFojl4qiQkd"
    @base_url = request.params
    if @base_url.key?("code")
      @code = @base_url[:code]
      get_access_tokens
      get_user_email
      get_calendars
    end
  end
  
  def get_access_tokens
    form_data = {
      "redirect_uri" => @redirect_uri,
      "client_id" => @client_id,
      "client_secret" => @client_secret,
      "code" => @code,
      "grant_type" => "authorization_code"
    }
    uri = URI.parse("https://accounts.google.com/o/oauth2/token") 
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true 
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(form_data)
    response = http.request(request)
    response_json = JSON.parse(response.body)
    @access_token = response_json["access_token"]
    @refresh_token = response_json["refresh_token"]
  end
  
  def get_user_email
    uri = URI.parse("https://www.googleapis.com/gmail/v1/users/me/profile?access_token=#{@access_token}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    @response_json = JSON.parse(response.body)
    @user_email = @response_json["emailAddress"]
  end
  
  def get_calendars
    uri = URI.parse("https://www.googleapis.com/calendar/v3/users/me/calendarList?access_token=#{@access_token}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    @response_json = JSON.parse(response.body)
    @calendars = ""
    @calendar_size = @response_json["items"].size
    @response_json["items"].each do |x|
      @calendars += "<option value='#{x["id"]}'>#{x["summary"]}</option>"
    end
  end
 
 
end