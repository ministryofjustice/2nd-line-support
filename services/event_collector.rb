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
    @redis = RedisClient.instance
  end



  def run
    @duty_roster.update         # this will update the redis key duty_roster:v2members if stale
    store_out_of_hours
    store_irm
  end



  private 


  def store_out_of_hours
    @redis.set 'ooh:members', WhosOutOfHours.list
  end

  def store_irm
    irm_schedules = @pagerduty.fetch_irm
    layer2 = extract_schedule_layer(irm_schedules, 'Layer 2')

    duty_irm = layer2['users'].first
    duty_irm_user = get_duty_irm_details(duty_irm['user']['id'])

    users = @pagerduty.fetch_todays_schedules_users(SupportApp.pager_duty_irm_schedule_id)
    duty_irm_user = users.detect{ |u| u['id'] == duty_irm['user']['id'] }
    @redis.set('duty_roster:v2irm', format_duty_irm_user(duty_irm_user))
  end


  def extract_schedule_layer(schedules, layer_name)
    schedules['schedule']['schedule_layers'].detect{ |layer| layer['name'] == layer_name }
  end


  def get_duty_irm_details(user_id)
    users = @pagerduty.fetch_todays_schedules_users(SupportApp.pager_duty_irm_schedule_id)
    duty_irm_user = users.detect{ |u| u['id'] == user_id }
  end

  def format_duty_irm_user(duty_irm_user)
    irm_telephone_dets = duty_irm_user['contact_methods'].detect{ |cm| cm['type'] == 'phone' }
    name = duty_irm_user['name']
    telephone = irm_telephone_dets['address']
    {
      'name' => name,
      'telephone' => telephone
    }
  end

end