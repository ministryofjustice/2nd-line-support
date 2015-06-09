require 'lib/ir_pagerduty'

class People
  def fetch(path, params)
    pd = IRPagerduty.new
    pd.fetch_json(path, params)
  end

  def fetch_users(params)
    fetch("users", params)['users']
  end

  def fetch_schedules(params)
    fetch("schedules", params)['schedules']
  end

  def fetch_schedules_users(schedule_id, params)
    fetch("schedules/#{schedule_id}/users", params)['users']
  end

  def fetch_irms
    today = Date.today
    self.fetch_schedules_users(SupportApp.pager_duty_irm_schedule_id, {
      :since => today.strftime('%FT%TZ'),
      :until => (today + 1).strftime('%FT%TZ')
    })
  rescue
    []
  end
end
