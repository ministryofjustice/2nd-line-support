require_relative 'builder/dev'
require_relative 'builder/webop'
require_relative 'builder/manager'
require_relative 'builder/contact_method'


module Builder
  #
  # Build Dev/Webops/Manager datastructures to be consumed by presenters/views
  #
  def template(name, rule, has_phone, contact_methods = [])
    {
      name:            name,
      rule:            rule,
      has_phone:       has_phone,
      contact_methods: contact_methods
    }
  end
end