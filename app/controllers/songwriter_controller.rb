class SongwriterController < ApplicationController

  skip_before_action :verify_authenticity_token

  LIST_IDS = {
    'development': '9f55092cd1',
    'production': 'ab1e1140c8'
  }.with_indifferent_access

  INTEREST_IDS = {
    'development': {
      'not_specified': '04a1e1cccd',
      'weekday_evenings': '37e29bd16e',
      'any_time': '504ea18484',
      'weekends': '6821c2dda2',
      'monday': '6b8825f41b',
      'tuesday': '9a716e531f',
      'wednesday': 'b7b130cd80',
      'thursday': 'ca629fec7b',
      'friday': 'f011a465b5',
      'saturday': 'f7186060a0',
      'sunday': 'fca10c5c78'
    },
    'production': {
      'not_specified': '037828068b',
      'weekday_evenings': '3cab084097',
      'any_time': '61f2967448',
      'weekends': '24a8351b7c',
      'monday': 'bc97ef97cc',
      'tuesday': 'ad0d2cf90a',
      'wednesday': 'ca7ddcf226',
      'thursday': '1f66bab918',
      'friday': '5b060b8628',
      'saturday': 'b1539ffa03',
      'sunday': '489ce75e11'
    }
  }.with_indifferent_access

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
    add_to_mailchimp(params['name'], params['email'], params['time_zone'], params['available_times'])
  end

  def add_to_mailchimp(name, email, time_zone, available_times)
    list_id = LIST_IDS[Rails.env]
    interests = build_interests(time_zone, available_times, INTEREST_IDS[Rails.env])
    url = "https://us14.api.mailchimp.com/3.0/lists/#{list_id}/members"
    headers = {
      'Authorization': 'apikey 0cdadcf56a8ca64012e9638d858a8200-us14'
    }
    body = {
      'email_address': email,
      'status': 'subscribed',
      'merge_fields': { 'NAME': name },
      'interests': interests
    }.to_json
    http_client = HTTPClient.new
    http_client.post(url, body, headers)
  end

  def build_interests(time_zone, available_times, interest_ids)
    return {} if time_zone.blank?
    hour_difference = (time_zone.split('(GMT')[1].split(')')[0].to_i + 5)
    interests = {}
    interests[interest_ids['monday']] = true
    interests[interest_ids['any_time']] = true
    interests
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
