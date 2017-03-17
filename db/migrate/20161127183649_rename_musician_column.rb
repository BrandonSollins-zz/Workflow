class RenameMusicianColumn < ActiveRecord::Migration
  def self.up
    rename_column :musicians, :keys, :keyboard
  end

  def self.down
    rename_column :musicians, :keyboard, :keys
  end
end