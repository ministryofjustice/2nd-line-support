require_relative '../../services/ir_pagerduty'
require_relative './component'

module HealthCheck
  class PagerdutyApi < Component
    def initialize
      @client = IRPagerduty.new
      super
    end

    def accessible?
      with_error_logging do
        !!@client.fetch_json('users')['active_account_users'] 
      end
    end
  end
end