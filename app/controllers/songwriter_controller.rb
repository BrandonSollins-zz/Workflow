class SongwriterController < ApplicationController

  skip_before_action :verify_authenticity_token

  LIST_IDS = {
    'development': '9f55092cd1',
    'production': 'ab1e1140c8'
  }.with_indifferent_access

  INTEREST_IDS = {
    'development': {
      'friday_early': '37e29bd16e',
      'friday_late': '1e0133be67',
      'friday_middle': 'a76330467e',
      'monday_early': 'ca629fec7b',
      'monday_late': 'ad8eabbafc',
      'monday_middle': '84fedc5d38',
      'not_specified': 'f011a465b5',
      'saturday_early': '04a1e1cccd',
      'saturday_late': 'c8db15fa67',
      'saturday_middle': '75578b451b',
      'sunday_early': 'fca10c5c78',
      'sunday_late': '39dd34b33c',
      'sunday_middle': '03c295bfa8',
      'thursday_early': '02eb29093e',
      'thursday_late': 'f7f4c12f35',
      'thursday_middle': '6821c2dda2',
      'tuesday_early': '9a716e531f',
      'tuesday_late': 'a70a062e13',
      'tuesday_middle': '373c9dfaa1',
      'wednesday_early': 'b25c3eb6c0',
      'wednesday_late': '3071d35c95',
      'wednesday_middle': 'f7186060a0'
    },
    'production': {
      'friday_early': '34a85af63b',
      'friday_late': '8437a1704e',
      'friday_middle': '1d661ec538',
      'monday_early': 'f61d0895c0',
      'monday_late': 'c9c95822fb',
      'monday_middle': '58b6f7ca34',
      'not_specified': '8995b3da87',
      'saturday_early': '8995864e3a',
      'saturday_late': 'cd113c5f8d',
      'saturday_middle': '7ff68457a2',
      'sunday_early': '8ec811957d',
      'sunday_late': '681768f015',
      'sunday_middle': '1f18ac7cfb',
      'thursday_early': '8c3f03dce9',
      'thursday_late': '51bf7b28d2',
      'thursday_middle': '495ca50464',
      'tuesday_early': '9a7b351ee0',
      'tuesday_late': 'a1c31f6e23',
      'tuesday_middle': '30a1fec7d7',
      'wednesday_early': '825669d68d',
      'wednesday_late': '0ac325ca8b',
      'wednesday_middle': '691c1abc71'
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
    return {"#{interest_ids['not_specified']}": true} if time_zone.blank? or available_times.blank?
    early = (9..16).to_a
    late = (17..22).to_a
    middle = (23..32).to_a
    day_period = (9..22).to_a
    evening_period = (17..22).to_a
    hour_difference = (time_zone.split('(GMT')[1].split(')')[0].to_i + 5)
    interests = {}
    if available_times.include?('Mondays')
      time_range = ((day_period.first + hour_difference)..(day_period.last + hour_difference)).to_a
      (early & time_range).any? ? interests[interest_ids['monday_early']] = true : nil
      (late & time_range).any? ? interests[interest_ids['monday_late']] = true : nil
      (middle & time_range).any? ? interests[interest_ids['monday_middle']] = true : nil
      time_range.first < 9 ? interests[interest_ids['sunday_middle']] = true : nil
      time_range.last > 32 ? interests[interest_ids['tuesday_early']] = true : nil
    end
    if available_times.include?('Tuesdays')
      time_range = ((day_period.first + hour_difference)..(day_period.last + hour_difference)).to_a
      (early & time_range).any? ? interests[interest_ids['tuesday_early']] = true : nil
      (late & time_range).any? ? interests[interest_ids['tuesday_late']] = true : nil
      (middle & time_range).any? ? interests[interest_ids['tuesday_middle']] = true : nil
      time_range.first < 9 ? interests[interest_ids['monday_middle']] = true : nil
      time_range.last > 32 ? interests[interest_ids['wednesday_early']] = true : nil
    end
    if available_times.include?('Wednesdays')
      time_range = ((day_period.first + hour_difference)..(day_period.last + hour_difference)).to_a
      (early & time_range).any? ? interests[interest_ids['wednesday_early']] = true : nil
      (late & time_range).any? ? interests[interest_ids['wednesday_late']] = true : nil
      (middle & time_range).any? ? interests[interest_ids['wednesday_middle']] = true : nil
      time_range.first < 9 ? interests[interest_ids['tuesday_middle']] = true : nil
      time_range.last > 32 ? interests[interest_ids['thursday_early']] = true : nil
    end
    if available_times.include?('Thursdays')
      time_range = ((day_period.first + hour_difference)..(day_period.last + hour_difference)).to_a
      (early & time_range).any? ? interests[interest_ids['thursday_early']] = true : nil
      (late & time_range).any? ? interests[interest_ids['thursday_late']] = true : nil
      (middle & time_range).any? ? interests[interest_ids['thursday_middle']] = true : nil
      time_range.first < 9 ? interests[interest_ids['wednesday_middle']] = true : nil
      time_range.last > 32 ? interests[interest_ids['friday_early']] = true : nil
    end
    if available_times.include?('Fridays')
      time_range = ((day_period.first + hour_difference)..(day_period.last + hour_difference)).to_a
      (early & time_range).any? ? interests[interest_ids['friday_early']] = true : nil
      (late & time_range).any? ? interests[interest_ids['friday_late']] = true : nil
      (middle & time_range).any? ? interests[interest_ids['friday_middle']] = true : nil
      time_range.first < 9 ? interests[interest_ids['thursday_middle']] = true : nil
      time_range.last > 32 ? interests[interest_ids['saturday_early']] = true : nil
    end
    if available_times.include?('Saturdays')
      time_range = ((day_period.first + hour_difference)..(day_period.last + hour_difference)).to_a
      (early & time_range).any? ? interests[interest_ids['saturday_early']] = true : nil
      (late & time_range).any? ? interests[interest_ids['saturday_late']] = true : nil
      (middle & time_range).any? ? interests[interest_ids['saturday_middle']] = true : nil
      time_range.first < 9 ? interests[interest_ids['friday_middle']] = true : nil
      time_range.last > 32 ? interests[interest_ids['sunday_early']] = true : nil
    end
    if available_times.include?('Sundays')
      time_range = ((day_period.first + hour_difference)..(day_period.last + hour_difference)).to_a
      (early & time_range).any? ? interests[interest_ids['sunday_early']] = true : nil
      (late & time_range).any? ? interests[interest_ids['sunday_late']] = true : nil
      (middle & time_range).any? ? interests[interest_ids['sunday_middle']] = true : nil
      time_range.first < 9 ? interests[interest_ids['saturday_middle']] = true : nil
      time_range.last > 32 ? interests[interest_ids['monday_early']] = true : nil
    end
    if available_times.include?('Weekends')
      time_range = ((day_period.first + hour_difference)..(day_period.last + hour_difference)).to_a
      if (early & time_range).any?
        interests[interest_ids['saturday_early']] = true
        interests[interest_ids['sunday_early']] = true
      end
      if (late & time_range).any?
        interests[interest_ids['friday_late']] = true
        interests[interest_ids['saturday_late']] = true
        interests[interest_ids['sunday_late']] = true
      end
      if (middle & time_range).any?
        interests[interest_ids['friday_middle']] = true
        interests[interest_ids['saturday_middle']] = true
        interests[interest_ids['sunday_middle']] = true
      end
      hour_difference < 0 ? interests[interest_ids['friday_early']] = true : nil
      hour_difference > 0 ? interests[interest_ids['sunday_middle']] = true : nil
      hour_difference > 10 ? interests[interest_ids['monday_early']] = true : nil
    end
    if available_times.include?('Weekday Evenings')
      time_range = ((evening_period.first + hour_difference)..(evening_period.last + hour_difference)).to_a
      if (early & time_range).any?
        interests[interest_ids['monday_early']] = true
        interests[interest_ids['tuesday_early']] = true
        interests[interest_ids['wednesday_early']] = true
        interests[interest_ids['thursday_early']] = true
        interests[interest_ids['friday_early']] = true
      end
      if (late & time_range).any?
        interests[interest_ids['monday_late']] = true
        interests[interest_ids['tuesday_late']] = true
        interests[interest_ids['wednesday_late']] = true
        interests[interest_ids['thursday_late']] = true
        interests[interest_ids['friday_late']] = true
      end
      if (middle & time_range).any?
        interests[interest_ids['monday_middle']] = true
        interests[interest_ids['tuesday_middle']] = true
        interests[interest_ids['wednesday_middle']] = true
        interests[interest_ids['thursday_middle']] = true
        interests[interest_ids['friday_middle']] = true
      end
      if time_range.last > 32
        interests[interest_ids['tuesday_early']] = true
        interests[interest_ids['wednesday_early']] = true
        interests[interest_ids['thursday_early']] = true
        interests[interest_ids['friday_early']] = true
        interests[interest_ids['saturday_early']] = true
      end
    end
    if available_times.include?('Any Time')
      time_range = ((day_period.first + hour_difference)..(day_period.last + hour_difference)).to_a
      if (early & time_range).any?
        interests[interest_ids['monday_early']] = true
        interests[interest_ids['tuesday_early']] = true
        interests[interest_ids['wednesday_early']] = true
        interests[interest_ids['thursday_early']] = true
        interests[interest_ids['friday_early']] = true
        interests[interest_ids['saturday_early']] = true
        interests[interest_ids['sunday_early']] = true
      end
      if (late & time_range).any?
        interests[interest_ids['monday_late']] = true
        interests[interest_ids['tuesday_late']] = true
        interests[interest_ids['wednesday_late']] = true
        interests[interest_ids['thursday_late']] = true
        interests[interest_ids['friday_late']] = true
        interests[interest_ids['saturday_late']] = true
        interests[interest_ids['sunday_late']] = true
      end
      if (middle & time_range).any?
        interests[interest_ids['monday_middle']] = true
        interests[interest_ids['tuesday_middle']] = true
        interests[interest_ids['wednesday_middle']] = true
        interests[interest_ids['thursday_middle']] = true
        interests[interest_ids['friday_middle']] = true
        interests[interest_ids['saturday_middle']] = true
        interests[interest_ids['sunday_middle']] = true
      end
      if time_range.last > 32
        interests[interest_ids['tuesday_early']] = true
        interests[interest_ids['wednesday_early']] = true
        interests[interest_ids['thursday_early']] = true
        interests[interest_ids['friday_early']] = true
        interests[interest_ids['saturday_early']] = true
        interests[interest_ids['sunday_early']] = true
        interests[interest_ids['monday_early']] = true
      end
    end
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
