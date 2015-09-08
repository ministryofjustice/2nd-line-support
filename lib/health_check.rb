module HealthCheck
  #
  # Check all application dependencies are accessible
  #  -> Pager Duty
  #  -> Zendesk
  #
  require_relative 'health_check/pagerduty_api'
  require_relative 'health_check/zendesk_api'
end

