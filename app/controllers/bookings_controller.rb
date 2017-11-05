class BookingsController < ApplicationController

  def show
  end

  def index
    @instruments = [
      "guitar", "bass", "drums"
    ]
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
    @booking_id = new_booking.id
  end

end
