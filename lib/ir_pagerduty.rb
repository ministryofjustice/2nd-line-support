require 'pagerduty/full'

class IRPagerduty < PagerDuty::Full
  def initialize
    @apikey = SupportApp.pager_duty_token
    @subdomain = SupportApp.pager_duty_subdomain
  end

  def fetch_json(path, params)
    res = self.api_call(path, params)

    case res
      when Net::HTTPSuccess
        JSON.parse(res.body)
      else
        res.error!
    end
  end
end