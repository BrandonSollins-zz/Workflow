class MusicianController < ApplicationController

  def show    
    if Musician.exists?(params["id"])
      @musician = Musician.find(params["id"]) 
      @bookings = Booking.all.select{ |x| x.chosen_musicians.include?(params["id"].to_i) unless x.chosen_musicians.nil? }.sort_by{ |x| x.completed_at }
      access_token = get_access_token(@musician.refresh_token)
      max_date = Time.now + 60*60*24*30
      @busy_times = get_busy_times(@musician.email, Time.now, max_date, access_token)
      if @busy_times.empty?
        @busy_header = "No busy times found for the next 30 days"
      else
	@busy_header = "Busy times for the next 30 days (#{(Time.now).strftime("%D")} to #{max_date.strftime("%D")})"
      end
    else
      @musician = "Musician not found"
    end
  end
  
  def index
    
  end

end