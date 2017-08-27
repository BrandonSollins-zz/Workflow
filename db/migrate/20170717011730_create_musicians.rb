class CreateMusicians < ActiveRecord::Migration[5.0]

  def up
    create_table :musicians do |t|
      t.timestamps
      t.string  "name"
      t.string  "email"
      t.string  "primary_instrument"
      t.string  "access_token"
      t.string  "refresh_token"
      t.text  "phone_number"
      t.text  "calendar_ids"
    end
  end

  def down
    drop_table :musicians
  end

end
