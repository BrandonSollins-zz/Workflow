class BookingsController < ApplicationController

  STUDIO_NUMBER = "studio1"

  GUITAR_LIST = [
    {"name": "guitar1", "phone_number": "guitar1"},
    {"name": "guitar2", "phone_number": "guitar2"}
  ]

  BASS_LIST = [
    {"name": "bass1", "phone_number": "bass1"},
    {"name": "bass2", "phone_number": "bass2"}
  ]

  DRUM_LIST = [
    {"name": "drum1", "phone_number": "drum1"},
    {"name": "drum2", "phone_number": "drum2"}
  ]

  INSTRUMENT_LIST = [
    "guitar", "bass", "drums"
  ]

  def show
  end

  def index
    @instruments = INSTRUMENT_LIST
  end

  def create
    booking_params = params[:booking]
    instruments = booking_params[:instruments].select { |x| !x.blank? }
    statuses = {}
    statuses[:studio_times] = {}
    statuses[:musicians] = {}
    statuses[:instruments] = {}
    instruments.each do |instrument|
      statuses[:instruments][instrument.to_sym] = "Incomplete"
      statuses[:musicians][instrument.to_sym] = []
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
    puts "message_studio"
    # check if studio needs to be messaged
      # if it does, find the next time to message, add it to the booking status, and send the message!
      # if it does not, trigger message_musicians
    if booking.studio == 'WHP'
      message_musicians(booking)
    else
      checked_times = booking.statuses[:studio_times].keys
      remaining_times = booking.possible_times - checked_times
      time_to_message = remaining_times[0]
      if time_to_message.blank?
        message_dane("No more available times to check with the studio")
      else
        studio = booking.studio
        required_instruments = booking.instruments.join(', ')
        message = "New Custom-Tracks.com order! " \
          "Is #{studio} available #{time_to_message}? " \
          "Instruments: #{required_instruments}" \
          "If yes, click here: " \
          "If no, click here: " \
          "Thanks!"
        send_message(message, STUDIO_NUMBER)
        booking.statuses[:studio_times][time_to_message] = "Message Sent"
        booking.save!
      end
    end
  end

  def message_musicians(booking, instrument = nil)
    puts "message_musicians"
    # Find musicians to message (MUSICIAN_LIST[instrument] - messaged_musicians)
      # If instrument is nil, check for all instruments that are in self.instruments
      # If instrument is not nil, only check for the instrument listed (this applied to when a musician rejects, or the clock job is ran)
    # Add the musicians to status
    # Send the message to the musicians!
  end

  def studio_reject
    # Add rejected time to status
    # Message studio again
    booking = Booking.find(params[:id])
    booking.statuses[:studio_times][booking[:statuses][:studio_times].keys[-1]] = "Rejected"
    booking.save!
    message_studio(booking)
  end

  def studio_confirm
    # Add confirmed time to status
    # Trigger message_musicians
    booking = Booking.find(params[:id])
    booking.statuses[:studio_times][booking[:statuses][:studio_times].keys[-1]] = "Confirmed"
    booking.save!
    message_musicians(booking)
  end

  def musician_reject
    # Add rejected musician to status
    # Trigger message_musicians(instrument to check for)
  end

  def musician_confirm
    # Add confimed musician to status
    # Change status of instrument in status
      # If all instruments are now confirmed, trigger reconfirm with studio
      # If not, do nothing
  end

  def reconfirm_studio
  end

  def send_message(message, phone_number)
    puts "send_message - #{message}, #{phone_number}"
  end

  def message_dane(message)
    puts "message_dane - #{message}"
  end

end
