class Email < ActiveRecord::Base

  INSTRUMENT_MAP = {
    "Electric Guitar" => "Guitar",
    "Keys/Piano" => "Keys/Piano",
    "Bass Guitar" => "Bass",
    "Drums" => "Drums"
  }

  def trigger_workflow
  
    ### Workflow steps:
    # 1. Parse data to get all needed fields including: 
    #      Instruments, available days and times; return as hash
    email_data = parse_data(data)
    
    # 2. Query DB for musicians with the appropriate instruments
    musicians = get_musicians(email_data[:instruments])
    
    # 3. Get client and studio availability
    studio_client_avail = get_studio_client_avail(email_data)
    
    # 4. Get musicians that are avaiable during the times above
    available_musicians = get_available_musicians(studio_client_avail, musicians)
    
    # 5. Get all times that have a full group of musicians
    possible_times = get_times_and_musicians(available_musicians, email_data)
    
    # 6. Create new booking
    booking = create_booking(available_musicians, possible_times, email_data) 
    
    # 6. Select musicians to text
    message_musicians(booking.id)
        
  end
  
  def parse_data(data)
    ### NOTE: MOST LIKELY TO CHANGE AS THE FORM CHANGES ###
    instruments = data.split("Select your instrument:")[1].split("Notes")[0].gsub("\n", "").split(", ")
    utc_offset = data.split("What timezone are you in?")[1].split("What's day are you most available?")[0].split()[-1].gsub("\n", "").gsub("−", "-")
    primary_day = data.split("What's day are you most available?")[1].split("Select your available times")[0].gsub("\n", "")
    primary_times = data.split("Select your available times.")[1].split("Would you like to add another day you're available?")[0].gsub("\n", "").split(", ")
    primary_date_times = convert_times(primary_day, primary_times, utc_offset)
    if data.include?("Ok, which day?")
      secondary_day = data.split("Ok, which day?")[1].split("Select your available times")[0].gsub("\n", "")
      secondary_times = data.split("Ok, which day?")[1].split("Select your available times.")[1].split("Log in to view or download your responses at")[0].gsub("\n", "").split(", ")
      secondary_date_times = convert_times(secondary_day, secondary_times, utc_offset)
      primary_date_times += secondary_date_times
    else
      nil
    end
    return_data = {
      :instruments => instruments,
      :date_times => primary_date_times.sort
    }
    return_data
  end
  
  def convert_times(day, times, offset)
    ### This is used to convert all times to UTC
    date_times = []
    times.each do |time|
      date_time = "#{day} #{time} #{offset}"
      formatted_date_time = DateTime.parse(date_time).new_offset(0)
      date_times.push(formatted_date_time)
    end
    date_times
  end
  
  def get_musicians(instruments)
    musicians = Hash.new
    instruments.each do |inst|
      instrument = INSTRUMENT_MAP[inst]
      primary_query = Musician.all(:conditions => "primary_instrument = '#{instrument}'")
      if primary_query.count == 0
        secondary_query = Musician.all(:conditions => "secondary_instrument = '#{instrument}'") 
        musicians[instrument] = secondary_query       
      else
        musicians[instrument] = primary_query
      end
   
    end
    musicians
  end
  
  def get_studio_client_avail(client_data)
    # Get min and max days of client
    client_times = client_data[:date_times]
    min_date = client_times[0]
    max_date = client_times[-1]
    
    # Query calendar for all free times between min & max date
    studio = Musician.first
    access_token = get_access_token(studio[:refresh_token])
    studio_busy_times = get_busy_times(studio.email, min_date, max_date, access_token)
    
    # Delete all client times that the studio is busy
    available_times = get_available_times(client_times, studio_busy_times)
    available_times
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
  
  def get_busy_times(calendar_ids, min_date, max_date, access_token)
    form_data = {
      "items" => [{:id => calendar_ids}],
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
  
  
  def get_available_times(free_times, busy_times)
    available_times = []
    free_times.each do |free|
      free_time = true
      busy_times.each do |busy|
        if free.between?(busy[0], busy[1])
          free_time = false
        elsif (free + 1.hours).between?(busy[0], busy[1])
          free_time = false
        end
      end
      if free_time
        available_times.push(free)
      end
    end
    available_times
  end
    
  def get_available_musicians(available_times, musicians)
    available_musicians = {}
    min_date = available_times.sort[0]
    max_date = available_times.sort[-1]
    musicians.keys.each do |key|
      musicians_instrument = []
      musicians[key].each do |musician|
        access_token = get_access_token(musician[:refresh_token])
        busy_times = get_busy_times(musician.email, min_date, max_date, access_token)    
        free_times = get_available_times(available_times, busy_times)
        unless free_times.blank?
          item = {
            :musician => musician,
            :free_times => free_times
          }
          musicians_instrument.push(item)
        end
      end
      available_musicians[key] = musicians_instrument
    end
    available_musicians
  end
  
  def get_times_and_musicians(available_musicians, email_data)
    # Find all times that have a group of musicians
    possible_times = []
    email_data[:date_times].each do |time|
      musicians = []
      available_musicians.keys.each do |key|
        available = []
        available_musicians[key].each do |musician|
          if musician[:free_times].include?(time)
            available << musician[:musician].id
          end
          unless available.blank?
            musicians << {:instrument => key, :musicians => available}
          end 
        end
      end
      unless email_data[:instruments].count != musicians.count
        possible_times << {:time => time, :available_musicians => musicians}
      end
    end 
    possible_times 
    
    ### TO ADD: If no possible times, send a message to Dane to notify
  end
  
  def create_booking(available_musicians, possible_times, data)
    booking = Booking.new
    booking.available_musicians = available_musicians
    booking.times_and_musicians = possible_times
    booking.available_times = data[:date_times]
    booking.required_instruments = data[:instruments].map{ |x| INSTRUMENT_MAP[x] }
    booking.save!
    booking
  end

  def message_musicians(booking_id)
    booking = Booking.find(booking_id)
    musicians_to_message = get_musicians_to_message(booking)
  end
  
  def get_musicians_to_message(booking)
  
    # Sort all times according to the following rules:
    # 1. Select all times between 10-6 EST, and sort from earliest to latest + add to list
    # 2. Select all times outside of 10-6 EST, and sort from earliest to latest + add to list
    # 3. For each time with multiple musicians, determine how many days since last booking. Sort musicians from smallest to largest
    
    # Break messages down by studio hours (10-6 EST)
    primary_messages = []
    secondary_messages = []
    booking.times_and_musicians.each do |tm|
      est_hour = (tm[:time].getutc + Time.zone_offset('EST')).hour
      if est_hour.between?(10,18)
        primary_messages << tm
      else
        secondary_messages << tm
      end
    end
    primary_messages = primary_messages.sort_by{ |x| x[:time] }
    secondary_messages = secondary_messages.sort_by{ |x| x[:time] }
    
    # From all bookings, get a hash of most recently completed bookings for all musicians
    all_bookings = Booking.all( :conditions => "completed_at is not null" )
    bookings_list = []
    all_bookings.each do |x|
      time = Time.now - x[:completed_at]
      x.chosen_musicians.each do |y|
        bookings_list << {:id => y, :time => time}
      end
    end
    
    # Build all messages based on most recent musician bookings
    all_messages = []
    primary_built_messages = build_messages(primary_messages, bookings_list)
    secondary_built_messages = build_messages(secondary_messages, bookings_list)
    all_messages = primary_built_messages + secondary_built_messages
 
    
    # Save messages
    booking.times_and_musicians_attempts = all_messages
    booking.save!
    
    # Send earliest recent booking message. If none, send earliest additional message. Add to booking.times_and_musicians_attempted
    if all_messages.blank?
      puts "Sending a message to Dane"   
    else
      puts "Sending a message to #{all_messages[0]}"
      # Using array[0], for each musician get phone number, instrument, and send get request with neximo
    end
  end
  
  def build_messages(messages, bookings_list)
    all_messages = []
    messages.each do |message|
      message_counts = message[:available_musicians].map{ |x| x[:musicians].count }.max
      selected_musicians = []
      (0..message_counts).each do |n|
      	temp_message = {:time => message[:time], :musicians_to_message => []}
        message[:available_musicians].each do |instrument|
          musicians = instrument[:musicians] - selected_musicians
          unless musicians.blank?
            earliest_times = musicians.map{ |x| {:id => x, :time => bookings_list.select{ |y| (y[:id] == x) && !(selected_musicians.include?(y[:id])) }.sort_by{ |x| x[:time] }[0][:time] } }
            selection = earliest_times.sort_by{ |x| x[:time] }[0][:id]
            temp_message[:musicians_to_message] << selection
            selected_musicians << selection
          end
        end
        unless temp_message[:musicians_to_message].blank?
          all_messages << temp_message
        end
      end
    end  
    all_messages
  end
end