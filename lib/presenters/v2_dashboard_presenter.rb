require 'json'
require_relative '../../models/redis_client'

class V2DashboardPresenter


  def initialize
    @redis = RedisClient.instance
    # TODO we load data with the dummy data to start off with, and then replace it with real data
    # as we implemnt the features.
    # we can get rid of the line below once we've done everything.
    @data = YAML::load_file(File.join(__dir__, '../../config/dummy_data.yml'))
    @data['status_bar_color'] = 'black'
  end



  def to_json
    read_duty_roster_data
    read_irm
    read_pagerduty_alerts
    read_zendesk_tickets

    @data.to_json
  end

  private


  def read_zendesk_tickets
    zendesk_tickets = @redis.get('zendesk:tickets')
    problems = zendesk_tickets.select{ |t| t['type'] == 'problem' }
    num_incidents = @redis.get('zendesk:incidents_in_last_week')

    @data['status_bar_color'] = 'amber' if zendesk_tickets.any?
    @data['status_bar_color'] = 'red' if problems.any?
    @data['tickets'] = @redis.get('zendesk:tickets')
    @data['status_bar_text'] = "#{num_incidents} incidents in the past week"
  end

  def read_pagerduty_alerts
    @data['number_of_alerts'] = @redis.count_keys('alert:pagerduty:*')
  end


  def read_duty_roster_data
    @data['duty_roster'] = DutyRosterMembers.v2_list
    ooh_members = @redis.get('ooh:members')
    ooh_members.each_with_index do |member, i|
      @data['duty_roster']["ooh_#{i + 1}"] = member['name']
    end
  end


  def read_irm
    irm = @redis.get('duty_roster:v2irm')
    @data['duty_roster']['irm'] = irm['name']
    @data['duty_roster']['irm_telephone'] = irm['telephone']
  end

end