class Booking < ApplicationRecord
  serialize :statuses, Hash
  serialize :instruments, Array
  serialize :possible_times, Array
  serialize :mp3_links, Array
  serialize :video_links, Array
  serialize :extra_links, Array

  after_create :message_studio # access the current booking with self

  GUITAR_LIST = [
    {"name": "guitar1", "phone_number": "guitar1"},
    {"name": "guitar2", "phone_number": "guitar2"}
  ]

  BASS_LIST = [
    {"name": "bass1", "phone_number": "bass1"},
    {"name": "bass2", "phone_number": "bass2"}
  ]

  def message_studio
    # check if studio needs to be messaged
      # if it does, find the next time to message, add it to the booking status, and send the message!
      # if it does not, trigger message_musicians
  end

  def message_musicians(instrument = nil)
    # Find musicians to message (MUSICIAN_LIST[instrument] - messaged_musicians)
      # If instrument is nil, check for all instruments that are in self.instruments
      # If instrument is not nil, only check for the instrument listed (this applied to when a musician rejects, or the clock job is ran)
    # Add the musicians to status
    # Send the message to the musicians!
  end

  def studio_reject
    # Add rejected time to status
    # Check for next available time
      # if available_time, trigger message_studio again
      # if no available_time, message Dane
  end

  def studio_confirm
    # Add confirmed time to status
    # Trigger message_musicians
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

end
