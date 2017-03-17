class CreateEmails < ActiveRecord::Migration
  def self.up
    create_table :emails do |t|
      t.text :data
      t.timestamp :completed_at

      t.timestamps
    end
  end

  def self.down
    drop_table :emails
  end
end
