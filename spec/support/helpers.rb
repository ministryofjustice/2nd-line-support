module Helpers
  def app
    SupportApp
  end

  def moj_pagerduty_schedule_regex
    #
    # regex for pagerduty scheduled users API to match this pattern
    # i.e. https://<subdomain>.pagerduty.com/api/v1/schedules/<scheduleId>/users/since=<timestamp>&until=<timestamp>
    #     (minus the timestamp params)
    #
    /#{SupportApp.pager_duty_subdomain}.pagerduty.com\/api\/v1\/schedules\/\w+\/users/
  end

  def basic_auth
    page.driver.header('Authorization', 'Basic '+ Base64.encode64('test pass:X')) 
  end

  def reset_roster!
    Capybara.app::ROSTER.clear!
  end

  def empty_incidents(count)
    {
      results: Array.new(count, {}),
      count:   count
    }.to_json
  end
end