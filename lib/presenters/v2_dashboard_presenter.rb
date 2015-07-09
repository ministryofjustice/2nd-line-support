require 'json'
require_relative '../../models/redis_client'

class V2DashboardPresenter


  def initialize
    @redis = RedisClient.instance
    # TODO we load data with the dummy data to start off with, and then replace it with real data
    # as we implemnt the features.
    # we can get rid of the line below once we've done everything.
    @data                      = {}
    
  end



  def to_json
    initialize_data_for_internal_view
    read_duty_roster_data
    read_pagerduty_alerts
    read_zendesk_tickets
    @data.to_json
  end

  def external
    initialize_data_for_external_view
    read_irm
    @data['tickets'] = get_zendesk_tickets
    @data
  end



  private

  def get_zendesk_tickets
    @redis.get('zendesk:tickets')
  end

  def initialize_data_for_internal_view
    @data['status_bar_status'] = 'ok'
    @data['duty_roster']       = []
    @data['services']          = []
    @data['services_status']   = 'ok'
    @data['tools']             = []
    @data['tools_status']      = 'ok'
  end

  def initialize_data_for_external_view
    @data['duty_roster']       = []
  end


  def read_zendesk_tickets
    zendesk_tickets = get_zendesk_tickets
    problems = zendesk_tickets.select{ |t| t['type'] == 'problem' }
    num_incidents = @redis.get('zendesk:incidents_in_last_week')

    @data['status_bar_status'] = 'warn' if zendesk_tickets.any?
    @data['status_bar_status'] = 'fail' if problems.any?
    @data['tickets'] = zendesk_tickets
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