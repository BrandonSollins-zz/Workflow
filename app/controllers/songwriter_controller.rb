class SongwriterController < ApplicationController

  skip_before_action :verify_authenticity_token

  def create
    return unless Songwriter.where("lower(email) like '#{params['email']}'").blank?
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

  def index
    @cities = Songwriter.uniq.pluck(:city)
    @regions = Songwriter.uniq.pluck(:region)
    @countries = Songwriter.uniq.pluck(:country)
    @time_zones = Songwriter.uniq.pluck(:time_zone)
    @data = build_data.to_json
  end

  def build_data
    possible_days = [
      'Weekday Evenings', 'Any Time', 'Weekends', 'Mondays', 'Tuesdays',
      'Wednesdays', 'Thursdays', 'Fridays', 'Saturdays', 'Sundays'
    ]
    all_data = {
      cities: {},
      regions: {},
      countries: {},
      time_zones: {},
      all_data: {}

    }
    possible_days.each do |day|
      td = Songwriter.where("available_times like '%#{day}%'")
      all_data[:all_data][day] = {count: td.count(), emails: td.map{ |x| x.email }}
    end
    td = Songwriter.where("available_times = ''")
    all_data[:all_data]["N/A"] = {count: td.count(), emails: td.map{ |x| x.email }}
    @cities.each do |city|
      all_data[:cities][city] = {}
      possible_days.each do |day|
        td = Songwriter.where("city = '#{city}' AND available_times like '%#{day}%'")
        all_data[:cities][city][day] = {count: td.count(), emails: td.map{ |x| x.email }}
      end
    end
    @regions.each do |region|
      all_data[:regions][region] = {}
      possible_days.each do |day|
        td = Songwriter.where("region = '#{region}' AND available_times like '%#{day}%'")
        all_data[:regions][region][day] = {count: td.count(), emails: td.map{ |x| x.email }}
      end
    end
    @countries.each do |country|
      all_data[:countries][country] = {}
      possible_days.each do |day|
        td = Songwriter.where("country = '#{country}' AND available_times like '%#{day}%'")
        all_data[:countries][country][day] = {count: td.count(), emails: td.map{ |x| x.email }}
      end
    end
    @time_zones.each do |tz|
      all_data[:time_zones][tz] = {}
      possible_days.each do |day|
        td = Songwriter.where("time_zone = '#{tz}' AND lower(available_times) like '%#{day}%'")
        all_data[:time_zones][tz][day] = {count: td.count(), emails: td.map{ |x| x.email }}
      end
    end
    all_data
  end

end
