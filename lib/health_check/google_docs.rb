require_relative '../../lib/support_rota_doc'
require_relative './component'

module HealthCheck
  class GoogleDocs < Component
    def initialize
      @data_source = SupportRotaDoc.default.url
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