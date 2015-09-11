require_relative '../lib/health_check'

module HealthCheck
  class Service
    COMPONENT_CLASSES =
    [
      HealthCheck::PagerdutyApi,
      HealthCheck::ZendeskApi,
    ]

    def initialize
      @components = COMPONENT_CLASSES.map(&:new)
    end

    def report
      if @components.all?(&:accessible?)
        HealthCheckReport.ok
      else
        HealthCheckReport.fail(@components.map(&:error_messages).flatten)
      end
    end

    private

    HealthCheckReport =
      Struct.new(:status, :messages) do
        def self.ok
          new('200', 'All Components OK')
        end

        def self.fail(errors)
          new('500', errors)
        end
      end
  end
end
