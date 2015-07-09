require 'json'
require_relative '../../models/redis_client'

class V2DashboardPresenter


  def initialize
    @redis = RedisClient.instance
    # TODO we load data with the dummy data to start off with, and then replace it with real data
    # as we implemnt the features.
    # we can get rid of the line below once we've done everything.
    @data = {}
    @data['status_bar_color'] = 'black'
    @data['duty_roster']      = []
    @data['services']         = []
    @data['services_color']   = 'black'
    @data['tools']            = []
    @data['tools_color']      = 'black'
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
    read_members
    read_irm
    read_ooh
  end

  def read_members
    members = @redis.get('duty_roster:v2members')
    members.each do |role, member_name|
      @data['duty_roster'] << make_member(member_name, role)
    end
  end

  def read_ooh
    ooh_members = @redis.get('ooh:members')
    ooh_members.each_with_index do |member, i|
      @data['duty_roster'] << make_member(member['name'], "ooh_#{i + 1}")
    end
  end


  def read_irm
    irm = @redis.get('duty_roster:v2irm')
    @data['duty_roster'] << make_member(irm['name'], 'irm', irm['telephone'])
  end


  def make_member(name, role, telephone = nil)
    member = {'name' => name, 'role' => role }
    member['telephone'] = telephone unless telephone.nil?
    member
  end

end