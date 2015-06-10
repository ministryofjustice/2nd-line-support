require 'lib/ir_pagerduty'

class People
  def fetch(path, params={})
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

  def fetch_users_contact_methods(user_id)
    fetch("users/#{user_id}/contact_methods")['contact_methods']
  end

  def fetch_todays_shedules_users(sid)
    today = Date.today
    users = fetch_schedules_users(sid, {
      :since => today.strftime('%FT%TZ'),
      :until => (today + 1).strftime('%FT%TZ')
    })

    users.each do |user|
      contact_methods = fetch_users_contact_methods(user['id'])
      user['contact_methods'] = contact_methods.select { |cm| SupportApp.pager_duty_contact_method_types.include? cm['type']  }
    end

    users
  rescue
    []
  end
end
