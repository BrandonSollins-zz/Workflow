class CreateSongwriters < ActiveRecord::Migration[5.0]

  def up
    create_table :songwriters do |t|
      t.timestamps
      t.string  "name"
      t.string  "email"
      t.string  "time_zone"
      t.string  "available_times"
      t.string  "ip_address"
    end
  end

  def down
    drop_table :songwriters
  end

end
