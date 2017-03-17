class AddEnumToEmail < ActiveRecord::Migration
  def self.up
    add_column :emails, :enum, :integer
  end

  def self.down
    remove_column :emails, :enum
  end
end
