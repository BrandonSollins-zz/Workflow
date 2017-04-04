class AddCalendarsToMusicians < ActiveRecord::Migration
  def self.up
    add_column :musicians, :calendar_ids, :text
  end

  def self.down
    remove_column :musicians, :calendar_ids
  end
end