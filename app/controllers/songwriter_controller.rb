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
      all_data: {}

    }
    possible_days.each do |day|
      td = Songwriter.where("lower(available_times) like '%#{day}%'")
      all_data[:all_data][day] = {count: td.count(), emails: td.map{ |x| x.email }}
    end
    @cities.each do |city|
      all_data[:cities][city] = {}
      possible_days.each do |day|
        td = Songwriter.where("city = '#{city}' AND lower(available_times) like '%#{day}%'")
        all_data[:cities][city][day] = {count: td.count(), emails: td.map{ |x| x.email }}
      end
    end
    @regions.each do |region|
      all_data[:regions][region] = {}
      possible_days.each do |day|
        td = Songwriter.where("region = '#{region}' AND lower(available_times) like '%#{day}%'")
        all_data[:regions][region][day] = {count: td.count(), emails: td.map{ |x| x.email }}
      end
    end
    @countries.each do |country|
      all_data[:countries][country] = {}
      possible_days.each do |day|
        td = Songwriter.where("country = '#{country}' AND lower(available_times) like '%#{day}%'")
        all_data[:countries][country][day] = {count: td.count(), emails: td.map{ |x| x.email }}
      end
    end
    all_data
  end

end
