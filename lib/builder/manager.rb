require_relative '../builder'

module Builder
  module Manager
    extend Builder
    extend self

    def hash(managers)
      managers.map do |manager|
        template(
          manager['name'], 
          'duty_manager', 
          false, 
          ContactMethod.hash(manager['contact_methods'])
        )
      end
    end
  end
end