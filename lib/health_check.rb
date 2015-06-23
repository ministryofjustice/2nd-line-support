module HealthCheck
  #
  # Check all application dependencies are accessible
  #  -> Google Docs
  #  -> Pager Duty
  #  -> Zendesk
  #
  require_relative 'health_check/google_docs'
  require_relative 'health_check/pagerduty_api'
  require_relative 'health_check/zendesk_api'
end

