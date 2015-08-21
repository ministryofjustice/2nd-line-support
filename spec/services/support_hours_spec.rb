require 'spec_helper'
require 'timecop'

require 'services/support_hours'

describe SupportHours do

  context 'In hours' do

    it 'returns true at 16:59' do
      Timecop.freeze(Time.local(2015, 1, 1, 16, 59)) do
        expect(described_class.support_hours?).to be true
      end
    end

    it 'returns true at 10:00' do
      Timecop.freeze(Time.local(2015, 1, 1, 10)) do
        expect(described_class.support_hours?).to be true
      end
    end

  end

  context 'Out of hours' do

    it 'returns false at 09:59' do
      Timecop.freeze(Time.local(2015, 1, 1, 9, 59)) do
        expect(described_class.support_hours?).to be false
      end
    end

    it 'returns false at 17:00' do
      Timecop.freeze(Time.local(2015, 1, 1, 17)) do
        expect(described_class.support_hours?).to be false
      end
    end

  end

end
