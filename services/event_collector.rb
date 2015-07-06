# This class is repsonsible for collecting data and writing it to the
# REDIS database in preparation for display on the dashboard by the
# Sinatra App

require_relative '../models/duty_roster.rb'

class EventCollector

  def initialize
    Excon.defaults[:ssl_verify_peer] = false
    @zendesk = nil
    @pagerduty = IRPagerduty.new
    @duty_roster = DutyRoster.default
    @redis = Redis.new(:url => ENV["REDISCLOUD_URL"])
  end



  def run
    @duty_roster.update         # this will update the redis key duty_roster:v2members if stale
    store_out_of_hours
  end



  private 


  def store_out_of_hours
    @redis.set 'ooh:members', WhosOutOfHours.list.to_json
  end

end