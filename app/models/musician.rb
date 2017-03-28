class Musician < ActiveRecord::Base
  serialize :calendar_ids, Array
end