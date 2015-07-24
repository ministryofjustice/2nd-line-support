require 'spec_helper'

module HealthCheck

  describe Component do
    describe '#accessible?' do
      it 'should raise a NotImplementedError' do
        expect {
          Component.new.accessible?
        }.to raise_error NotImplementedError, 'The #accessible? method should be implemented by subclasses'
      end
    end
  end

end