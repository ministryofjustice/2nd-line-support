require 'pagerduty/full'

class IRPagerduty < PagerDuty::Full
  def initialize
    super(SupportApp.pager_duty_token, SupportApp.pager_duty_subdomain)
  end

  def fetch_json(path, params={})
    res = self.api_call(path, params)

    case res
      when Net::HTTPSuccess
        JSON.parse(res.body)
      else
        res.error!
    end
  end

  def fetch_users_contact_methods(user_id)
    fetch_json("users/#{user_id}/contact_methods")['contact_methods']
  end

  def attach_contact_methods_to_user(user)
    contact_methods = fetch_users_contact_methods(user['id'])
    user['contact_methods'] = contact_methods.select { |cm|
      SupportApp.pager_duty_contact_method_types.include? cm['type']
    }
    user
  end

  def fetch_todays_schedules_users(sid)
    today = Date.today
    users = self.Schedule.users(
        sid,
        since_date=today.strftime('%FT%TZ'),
        until_date=(today + 1).strftime('%FT%TZ')
    )['users']

    # PagerDuty class has no method to get contact_methods so we must do it manually
    users.map { |user| attach_contact_methods_to_user(user) }
  rescue
    []
  end
end
