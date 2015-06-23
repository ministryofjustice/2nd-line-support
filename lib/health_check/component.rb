module HealthCheck
  class Component
    #
    # Define interface to check if component passes the healthcheck
    #
    def initialize
      @errors = []
    end

    def accessible?
      #
      # Checks if application can access component with supplied credentials
      # Null -> Boolean
      #
      raise NotImplementedError, 'The #accessible? method should be implemented by subclasses'
    end

    def error_messages
      #
      # Logs non-success response message from the component
      # Null -> Array[String]
      #
      @errors
    end

    def log_error
      #
      # Logs service inaccessible errors
      #
      @errors << "#{self.class} Error: component not accessible"
    end

    def log_unknown_error(e)
      #
      # Logs errors thrown when accessing a component
      # StandardError -> Null
      #
      @errors << "#{self.class} Error: #{e.message}\nDetails:#{e.backtrace}"
    end

    protected

    def with_error_logging(&block)
      block.call ? true : log_error && false
      
    rescue => err
      log_unknown_error(err)
      false
    end
  end
end