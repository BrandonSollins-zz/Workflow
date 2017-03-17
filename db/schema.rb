# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20161230210000) do

  create_table "bookings", :force => true do |t|
    t.text     "available_musicians"
    t.text     "available_times"
    t.datetime "time"
    t.datetime "completed_at"
    t.text     "required_instruments"
    t.text     "chosen_musicians"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "times_and_musicians"
    t.text     "times_and_musicians_attempted"
    t.text     "times_and_musicians_attempts"
  end

  create_table "emails", :force => true do |t|
    t.text     "data"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "message_id"
    t.integer  "enum"
  end

  create_table "musicians", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "primary_instrument"
    t.string   "secondary_instrument"
    t.string   "access_token"
    t.string   "refresh_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "phone_number"
  end

end
