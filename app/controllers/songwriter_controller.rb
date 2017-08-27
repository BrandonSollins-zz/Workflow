class SongwriterController < ApplicationController

  skip_before_action :verify_authenticity_token
  def create
    songwriter = Songwriter.new
    songwriter.name = params['name']
    songwriter.email = params['email']
    songwriter.time_zone = params['time_zone']
    songwriter.available_times = params['available_times']
    songwriter.ip_address = params['ip_address']
    location = Geocoder.address(params['ip_address'])
    songwriter.city = location.split(',')[0] rescue nil
    songwriter.region = location.split(',')[1] rescue nil
    songwriter.country = location.split(',')[2] rescue nil
    songwriter.save!
  end

end
