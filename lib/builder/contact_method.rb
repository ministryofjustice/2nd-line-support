require_relative '../builder'

module Builder
  module ContactMethod
    extend Builder
    extend self

    def hash(contact_methods)
      contact_methods.map(&method(:template))
    end

    private

    def template(contact_method)
      {
        type:    contact_method['type'],
        address: format_contact_method_address(contact_method),
        label:   contact_method['label'],
      }
    end

    def format_contact_method_address(contact_method)
      address = contact_method['address']

      if ['phone', 'SMS'].include? contact_method['type']
        address = 
          "(00) #{contact_method['country_code']} " + 
          "#{contact_method['phone_number'].reverse.gsub(/.{4}(?=.)/, '\0 ').reverse}"
      end

      address
    end
  end
end