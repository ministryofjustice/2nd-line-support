require_relative '../builder'

module Builder
  module Webop
    extend Builder
    extend self

    def hash(webops)
      webops.map { |webop| template(webop, 'webop', true) }
    end
  end
end