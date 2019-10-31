class CreateBookings < ActiveRecord::Migration[5.0]

  def up
    create_table :bookings do |t|
      t.timestamps
      t.string "instruments", array: true
      t.string "possible_times", array: true
      t.string "mp3_links", array: true
      t.string "video_links", array: true
      t.string "extra_links", array: true
      t.text "notes"
      t.string "studio"
      t.text "statuses"
      t.string "booking_status"
    end
  end

  def down
    drop_table :bookings
  end
end
