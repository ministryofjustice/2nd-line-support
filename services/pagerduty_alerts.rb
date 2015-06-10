require 'lib/ir_pagerduty'

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
  REFRESH_KEY = 'check_refresh'

  def reset_check
    PagerDutyCheck.destroy(REFRESH_KEY)
  end

  def is_check_needed?
    if PagerDutyCheck.exists?(REFRESH_KEY)
      return false
    end

    PagerDutyCheck.create_with_expire(REFRESH_KEY, true, SupportApp.pager_duty_refresh_interval)
    return true
  end

  def check_alerts
    if !self.is_check_needed?
      return
    end

    pd = IRPagerduty.new

    incs = pd.Incident.search(
      assigned_to_user = nil,
      incident_key = nil,
      status = "triggered,acknowledged",
      service = SupportApp.pager_duty_services
    )

    return self.process_incs(incs['incidents'])
  end

  def process_incs(incs)
    Alert.destroy_all("#{REDIS_KEY_PREFIX}:*")

    for inc in incs
      redis_key = "#{REDIS_KEY_PREFIX}:#{inc['id']}"
      Alert.create(redis_key, {
        message: {
          service: inc['service']['name'],
          description: inc['trigger_summary_data'],
        },
        acknowledged: inc['status']
      })
    end

    return incs.length
  end

end