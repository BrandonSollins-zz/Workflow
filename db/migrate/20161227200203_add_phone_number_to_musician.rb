class AddPhoneNumberToMusician < ActiveRecord::Migration
  def self.up
    add_column :musicians, :phone_number, :text
  end

  def self.down
    remove_column :musicians, :phone_number
  end
end
