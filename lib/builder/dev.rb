require_relative '../builder'

module Builder
  module Dev
    extend Builder
    extend self

    def hash(current_devs, next_devs)
      current_devs.map do |dev|
        has_phone = next_devs.include?(dev) || current_devs.count == 1
        template(dev, 'dev', has_phone)
      end
    end
  end
end