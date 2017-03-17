class CreateMusicians < ActiveRecord::Migration
  def self.up
    create_table :musicians do |t|
      t.string :name
      t.string :email
      t.string :primary_instrument
      t.string :secondary_instrument
      t.string :access_token
      t.string :refresh_token

      t.timestamps
    end
  end

  def self.down
    drop_table :musicians
  end
end
