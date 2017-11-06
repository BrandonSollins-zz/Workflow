class Booking < ApplicationRecord
  serialize :statuses, Hash
  serialize :instruments, Array
  serialize :possible_times, Array
  serialize :mp3_links, Array
  serialize :video_links, Array
  serialize :extra_links, Array
end
