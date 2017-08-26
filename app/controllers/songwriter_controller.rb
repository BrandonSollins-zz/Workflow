class SongwriterController < ApplicationController

  skip_before_action :verify_authenticity_token
  def create
    songwriter = Songwriter.new
    songwriter.name = params['name']
    songwriter.email = params['email']
    songwriter.time_zone = params['time_zone']
    songwriter.available_times = params['available_times']
    songwriter.ip_address = params['ip_address']
    songwriter.save!
  end

end
