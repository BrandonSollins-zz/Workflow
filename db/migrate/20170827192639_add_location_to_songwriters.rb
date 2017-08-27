class AddLocationToSongwriters < ActiveRecord::Migration[5.0]

  def up
    add_column :songwriters, :city, :string
    add_column :songwriters, :region, :string
    add_column :songwriters, :country, :string
  end

  def down
    remove_column :songwriters, :city
    remove_column :songwriters, :region
    remove_column :songwriters, :country
  end

end
