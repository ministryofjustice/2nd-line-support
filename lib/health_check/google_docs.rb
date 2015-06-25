require_relative '../../services/whos_on_duty'
require_relative './component'

module HealthCheck
  class GoogleDocs < Component
    def initialize
      @data_source = WhosOnDuty.data_url
      super
    end

    def accessible?
      with_error_logging do
        res = 
          Excon.get(
            @data_source, 
            headers: { 'Accept' => 'text/csv' }
          )
        
        res.status === 200
      end
    end
  end
end