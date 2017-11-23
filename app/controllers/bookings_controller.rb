class BookingsController < ApplicationController

  #STUDIO_NUMBER = "+17726313753"
  STUDIO_NUMBER = "+14079528945"

  #DANE_NUMBER = "+17726313753"
  DANE_NUMBER = "+13522294867"

  #TWILIO_NUMBER = "+17727424854"
  TWILIO_NUMBER = "+13523507838"

  ACOUSTIC_GUITAR_LIST = {
    #1 => { "name": "acoustic_guitar1", "phone_number": "+17726313753" },
    #2 => { "name": "acoustic_guitar2", "phone_number": "+17726313753" },
    1 => { "name": "Tommy Calton", "phone_number": "+14075799405" },
    2 => { "name": "Andrew Williams", "phone_number": "+13213162569" }
  }
  DRUMS_LIST = {
    #1 => { "name": "drums1", "phone_number": "+17726313753" },
    #2 => { "name": "drums2", "phone_number": "+17726313753" },
    1 => { "name": "Gerald Law", "phone_number": "+19413741741" },
    2 => { "name": "Jay Dolpus", "phone_number": "+14075086481" },
    3 => { "name": "Luis Rivera", "phone_number": "+13525301263" },
    4 => { "name": "Jerome Martin", "phone_number": "+19548267940" }
  }
  ELECTRIC_BASS_LIST = {
    #1 => { "name": "electric_bass1", "phone_number": "+17726313753" },
    #2 => { "name": "electric_bass2", "phone_number": "+17726313753" },
    1 => { "name": "Brandon Miller", "phone_number": "+14077492730" },
    2 => { "name": "Dex Wilborn", "phone_number": "+13213423779" },
    3 => { "name": "Al Castor", "phone_number": "+14076687256" }
  }
  ELECTRIC_GUITAR_LIST = {
    #1 => { "name": "electric_guitar1", "phone_number": "+17726313753" },
    #2 => { "name": "electric_guitar2", "phone_number": "+17726313753" },
    1 => { "name": "Andrew Williams", "phone_number": "+13213162569" },
    2 => { "name": "Brandon Wilson", "phone_number": "+14049184694" },
    3 => { "name": "Daniel Howard", "phone_number": "+13216628961" },
    4 => { "name": "Brandon Sollins", "phone_number": "+17726313753" }
  }
  KEYBOARD_LIST = {
    #1 => { "name": "keyboard1", "phone_number": "+17726313753" },
    #2 => { "name": "keyboard2", "phone_number": "+17726313753" },
    1 => { "name": "Assel Jean-Pierre Jr", "phone_number": "+14076708790" },
    2 => { "name": "Jeremy James", "phone_number": "+13522725820" }
  }
  LIVE_PIANO_LIST = {
    #1 => { "name": "live_piano1", "phone_number": "+17726313753" },
    #2 => { "name": "live_piano2", "phone_number": "+17726313753" },
    1 => { "name": "Assel Jean-Pierre Jr", "phone_number": "+14076708790" }
  }
  TENOR_SAX_LIST = {
    #1 => { "name": "tenor_sax1", "phone_number": "+17726313753" },
    #2 => { "name": "tenor_sax2", "phone_number": "+17726313753" },
    1 => { "name": "Dex Wilborn", "phone_number": "+13213423779" }
  }
  TRUMPET_LIST = {
    #1 => { "name": "trumpet1", "phone_number": "+17726313753" },
    #2 => { "name": "trumpet2", "phone_number": "+17726313753" },
    1 => { "name": "Matthew Mill", "phone_number": "+13216267502" }
  }
  UPRIGHT_BASS_LIST = {
    #1 => { "name": "upright_bass1", "phone_number": "+17726313753" },
    #2 => { "name": "upright_bass2", "phone_number": "+17726313753" },
    1 => { "name": "Brandon Miller", "phone_number": "+14077492730" }
  }
  VIOLIN_LIST = {
    #1 => { "name": "violin1", "phone_number": "+17726313753" },
    #2 => { "name": "violin2", "phone_number": "+17726313753" },
    1 => { "name": "Jared Burnett", "phone_number": "+14073103204" }
  }

  INSTRUMENT_LIST = {
    "acoustic_guitar" => 1,
    "drums" => 2,
    "electric_bass" => 3,
    "electric_guitar" => 4,
    "keyboard" => 5,
    "live_piano" => 6,
    "tenor_sax" => 7,
    "trumpet" => 8,
    "upright_bass" => 9,
    "violin" => 10
  }

  account_sid = Key.where("platform = 'twilio'")[0].keys[:account_sid]
  token = Key.where("platform = 'twilio'")[0].keys[:token]
  TWILIO_CLIENT = Twilio::REST::Client.new(account_sid, token)

  def show
    @booking = Booking.find(params[:id])
  end

  def show_status
    @booking = Booking.find(params[:id])
    @acoustic_guitar_list = ACOUSTIC_GUITAR_LIST
    @drums_list = DRUMS_LIST
    @electric_bass_list = ELECTRIC_BASS_LIST
    @electric_guitar_list = ELECTRIC_GUITAR_LIST
    @keyboard_list = KEYBOARD_LIST
    @live_piano_list = LIVE_PIANO_LIST
    @tenor_sax_list = TENOR_SAX_LIST
    @trumpet_list = TRUMPET_LIST
    @upright_bass_list = UPRIGHT_BASS_LIST
    @violin_list = VIOLIN_LIST
  end

  def index
    @instruments = INSTRUMENT_LIST.keys
  end

  def create
    booking_params = params[:booking]
    instruments = booking_params[:instruments].select { |x| !x.blank? }
    statuses = {}
    statuses[:studio_reconfirmed] = "Incomplete"
    statuses[:studio_times] = {}
    statuses[:musicians] = {}
    statuses[:instruments] = {}
    instruments.each do |instrument|
      statuses[:instruments][instrument.to_sym] = "Incomplete"
      statuses[:musicians][instrument.to_sym] = {}
    end
    new_booking = Booking.new(
      instruments: instruments,
      possible_times: booking_params[:dates].split("\r\n"),
      mp3_links: booking_params[:mp3_links].split("\r\n"),
      video_links: booking_params[:video_links].split("\r\n"),
      extra_links: booking_params[:extra_links].split("\r\n"),
      notes: booking_params[:notes],
      studio: booking_params[:studio],
      statuses: statuses,
      booking_status: "Active"
    )
    new_booking.save!
    message_studio(new_booking)
    @booking_id = new_booking.id
  end

  def message_studio(booking)
    if booking.studio == 'WHP'
      booking.statuses[:studio_times][booking.possible_times[0]] = "Confirmed (#{Time.now})"
      booking.save!
      message_musicians(booking)
    else
      studio = booking.studio
      required_instruments = booking.instruments.join(', ').gsub('_', ' ')
      message = "New Custom-Tracks.com order! \n\n" \
        "Instruments: #{required_instruments} \n\n" \
        "Studio: #{studio} \n\n" \
        "Please click the link next to the time that would work best for the studio. \n\n"
      booking.possible_times.each_with_index do |time, index|
        message += "#{time} - app.custom-tracks.com/b/#{booking.id}/sc?r=0&t=#{index} \n\n" \
      end
      message += "If no days/times work, click here: app.custom-tracks.com/b/#{booking.id}/sr?r=0 \n\n"
      message += "Thanks!"
      send_message(message, STUDIO_NUMBER)
      booking.statuses[:studio_times]["Initial contact"] = "Message Sent (#{Time.now})"
      booking.save!
    end
  end

  def build_musician_message(booking, instrument)
    time_to_message = booking.statuses[:studio_times].keys[-1]
    musician_list = eval("#{instrument}_list".upcase)
    available_musicians = musician_list.keys
    contacted_musicians = booking.statuses[:musicians][instrument.to_sym].keys
    musician_to_message = (available_musicians - contacted_musicians)[0]
    if musician_to_message.blank?
      message_dane("No more musicians available to message (#{instrument}) for booking ##{booking.id}")
      booking.booking_status = "Failed - Messaged Dane (#{Time.now})"
      booking.save!
      return
    end
    phone_number = musician_list[musician_to_message][:phone_number]
    message = "New Custom-Tracks.com session! \n\n" \
      "Are you available #{time_to_message} for a session at #{booking.studio}? \n\n" \
      "If yes, click here: app.custom-tracks.com/b/#{booking.id}/mc?i=#{INSTRUMENT_LIST[instrument]}&n=#{musician_to_message} \n\n" \
      "If no, click here: app.custom-tracks.com/b/#{booking.id}/mr?i=#{INSTRUMENT_LIST[instrument]}&n=#{musician_to_message} \n\n" \
      "Thanks!"
    send_message(message, phone_number)
    booking.statuses[:musicians][instrument.to_sym][musician_to_message] = "Message Sent (#{Time.now})"
    booking.save!
  end

  def message_musicians(booking, instrument = nil)
    if instrument.blank?
      booking.instruments.each do |instrument|
        build_musician_message(booking, instrument)
      end
    else
      build_musician_message(booking, instrument)
    end
  end

  def studio_reject
    booking = Booking.find(params[:id])
    reconfirm = params[:r].to_i == 0 ? false : true
    if reconfirm
      booking.statuses[:studio_reconfirmed] = "Rejected (#{Time.now})"
      booking.booking_status = "Failed - Messaged Dane (#{Time.now})"
      booking.save!
      message_dane("Studio rejected reconfirm - Booking ##{booking.id}")
    elsif !booking.statuses[:studio_times].values[-1].include?("Message Sent")
      @double_click = true
      return
    else
      booking.statuses[:studio_times][booking[:statuses][:studio_times].keys[-1]] = "Rejected (#{Time.now})"
      booking.booking_status = "Failed - Messaged Dane (#{Time.now})"
      booking.save!
      message_dane("The studio isn't available - Booking ##{booking.id}")
    end
  end

  def studio_confirm
    booking = Booking.find(params[:id])
    reconfirm = params[:r].to_i == 0 ? false : true
    time = params[:t].to_i
    if reconfirm
      booking.statuses[:studio_reconfirmed] = "Confirmed (#{Time.now})"
      booking.booking_status = "Completed (#{Time.now})"
      booking.save!
      reconfirm_musicians(booking)
    elsif !booking.statuses[:studio_times].values[-1].include?("Message Sent")
      @double_click = true
      return
    else
      booking.statuses[:studio_times][booking.possible_times[time]] = "Confirmed (#{Time.now})"
      booking.save!
      message_musicians(booking)
    end
  end

  def musician_reject
    booking = Booking.find(params[:id])
    instrument = INSTRUMENT_LIST.rassoc(params[:i].to_i)[0]
    musician = params[:n].to_i
    if !booking.statuses[:musicians][instrument.to_sym][musician].include?("Message Sent")
      @double_click = true
      return
    end
    booking.statuses[:musicians][instrument.to_sym][musician] = "Rejected (#{Time.now})"
    booking.save!
    last_musician_messaged = booking.statuses[:musicians][instrument.to_sym].keys[-1]
    if musician == last_musician_messaged
      message_musicians(booking, instrument)
    end
  end

  def musician_confirm
    booking = Booking.find(params[:id])
    instrument = INSTRUMENT_LIST.rassoc(params[:i].to_i)[0].to_sym
    musician = params[:n].to_i
    instrument_status = booking.statuses[:instruments][instrument]
    musician_status = booking.statuses[:musicians][instrument][musician]
    if !booking.statuses[:musicians][instrument.to_sym][musician].include?("Message Sent")
      @double_click = true
      return
    end
    if (instrument_status == "Confirmed") & (!musician_status.include?("Confirmed"))
      booking.statuses[:musicians][instrument.to_sym][musician] = "Late response (#{Time.now})"
      booking.save!
      @late_response = true
      return
    end
    booking.statuses[:musicians][instrument.to_sym][musician] = "Confirmed (#{Time.now})"
    booking.statuses[:instruments][instrument] = "Confirmed"
    booking.save!
    if booking.statuses[:instruments].values.all? { |x| x == "Confirmed" }
      reconfirm_studio(booking)
    end
  end

  def reconfirm_musicians(booking)
    booking_time = booking.statuses[:studio_times].keys[-1]
    booking.statuses[:instruments].keys.each do |instrument|
      confirmed_musician = booking.statuses[:musicians][instrument].select{ |k,v| v.include?("Confirmed") }
      phone_number = eval("#{instrument}_list".upcase)[confirmed_musician.keys[0]][:phone_number]
      message = "We have a booking! \n\n" \
        "See you at #{booking.studio} at #{booking_time} for recording #{instrument.to_s.gsub('_', ' ')}. \n\n" \
        "Click below to see the song and session info: \n\n" \
        "app.custom-tracks.com/bookings/#{booking.id}"
      send_message(message, phone_number)
    end
    message_dane("Booking ##{booking.id} has been fully booked!")
  end

  def reconfirm_studio(booking)
    time = booking.statuses[:studio_times].keys[-1]
    instruments = booking.instruments.join(', ').gsub('_', ' ')
    message = "Musicians are all set for: \n\n" \
      "Studio -  #{booking.studio} \n\n" \
      "Time -  #{time} \n\n" \
      "Instruments - #{instruments} \n\n" \
      "To confirm the booking, click here: app.custom-tracks.com/b/#{booking.id}/sc?r=1 \n\n" \
      "If things have changed, click here: app.custom-tracks.com/b/#{booking.id}/sr?r=1 \n\n" \
      "Thanks!"
    send_message(message, STUDIO_NUMBER)
    booking.statuses[:studio_reconfirmed] = "Message Sent (#{Time.now})"
    booking.save!
  end

  def send_message(message, phone_number)
    #puts "send_message - #{message}, #{phone_number}"
    message = TWILIO_CLIENT.messages.create(
        body: message,
        to: phone_number,
        from: TWILIO_NUMBER
    )
  end

  def message_dane(message)
    #puts "message_dane - #{message}"
    message = TWILIO_CLIENT.messages.create(
        body: message,
        to: DANE_NUMBER,
        from: TWILIO_NUMBER
    )
  end

  def check_messaged_musicians
    Booking.where("booking_status = 'Active'").each do |booking|
      booking.instruments.each do |instrument|
        last_message = booking.statuses[:musicians][instrument.to_sym].values[-1]
        return if last_message.blank?
        instrument_status = booking.statuses[:instruments][instrument.to_sym]
        status = last_message.split(' (')[0]
        time = last_message.split(' (')[1].to_time
        time_difference = ((Time.now - time)/60)
        if instrument_status == 'Incomplete' and status == 'Message Sent' and time_difference > 30
          message_musicians(booking, instrument)
        end
      end
    end
  end

end
