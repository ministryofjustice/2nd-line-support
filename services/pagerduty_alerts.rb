require_relative 'ir_pagerduty'
require_relative '../models/redis_struct'

class PagerDutyCheck < RedisStruct
  def self.key_prefix
    "pagerduty_refresh"
  end

  def self.create_with_expire(key, data, expire)
    cache_key = cache_key(key)
    self.redis.set(cache_key, data)
    self.redis.expire(cache_key, expire)
  end
end

class PagerDutyAlerts
  REDIS_KEY_PREFIX = 'pagerduty'
  REFRESH_KEY      = 'check_refresh'

  def check_alerts
    return unless check_needed?

    services_to_check = SupportApp.pager_duty_services
    # services_to_check = nil

    incs = IRPagerduty.new.Incident.search(
      assigned_to_user = nil,
      incident_key     = nil,
      status           = "triggered,acknowledged",
      service          = services_to_check
    )['incidents']

    process_incs(incs)
  end

  def reset_check
    PagerDutyCheck.destroy(REFRESH_KEY)
  end

  def check_needed?
    return false if PagerDutyCheck.exists?(REFRESH_KEY)

    PagerDutyCheck.create_with_expire(REFRESH_KEY, true, SupportApp.pager_duty_refresh_interval)
    true
  end

  private

  def process_incs(incs)
    Alert.destroy_all("#{REDIS_KEY_PREFIX}:*")

    incs.map { |inc|
      redis_key = "#{REDIS_KEY_PREFIX}:#{inc['id']}"

      Alert.create(redis_key, {
        message: {
          service:     inc['service']['name'],
          description: inc['trigger_summary_data'],
        },
        acknowledged:  inc['status']
      })
    }.length
  end
end