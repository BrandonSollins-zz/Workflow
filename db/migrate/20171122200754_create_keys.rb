class CreateKeys < ActiveRecord::Migration[5.0]

  def up
    create_table :keys do |t|
      t.string "platform"
      t.text "keys"
    end
  end

  def down
    drop_table :keys
  end

end
