# This class is repsonsible for collecting data and writing it to the
# REDIS database in preparation for display on the dashboard by the
# Sinatra App

require_relative '../models/duty_roster.rb'

class EventCollector

  def initialize
    Excon.defaults[:ssl_verify_peer] = false
    @zendesk = nil
    @pagerduty = nil
    @duty_roster = DutyRoster.default
  end



  def run
   @duty_roster.update
 end

end