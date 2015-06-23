require_relative '../../services/zendesk'
require_relative './component'

module HealthCheck
  class ZendeskApi  < Component
    def initialize
      @client = Zendesk.new.client
      super
    end

    def accessible?
      with_error_logging do
        !!@client.current_user['name']
      end
    end 
  end
end