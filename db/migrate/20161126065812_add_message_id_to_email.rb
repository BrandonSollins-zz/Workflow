class AddMessageIdToEmail < ActiveRecord::Migration
  def self.up
    add_column :emails, :message_id, :text
  end

  def self.down
    remove_coumn :emails, :message_id
  end
end
