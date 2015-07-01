require 'json'
require 'spec_helper'

require 'services/zendesk'
require 'support/request_handlers'

describe Zendesk do
  include RequestHandlers

  def empty_incidents(count)
    {
      results: Array.new(count, {}),
      count:   count
    }.to_json
  end

  let(:zendesk) { Zendesk.new }

  describe '#incidents_for_the_past_week' do
    context 'when no incidents have occurred' do
      it 'should return 0' do
        zendesk_api_returns(empty_incidents(0))

        expect(zendesk.incidents_for_the_past_week).to eq(0)
      end
    end

    context 'when 1 incident has occurred' do
      it 'should return 1' do
        zendesk_api_returns(empty_incidents(1))

        expect(zendesk.incidents_for_the_past_week).to eq(1)
      end
    end

    context 'when 5 incidents have occurred' do
      it 'should return 5' do
        zendesk_api_returns(empty_incidents(5))

        expect(zendesk.incidents_for_the_past_week).to eq(5)
      end
    end
  end

  describe '#active_incidents' do
    it 'should return a collection of active incidents' do
      zendesk_api_returns({
        :results => [{
          'description': 'A description',
          'id': 1234
        }], 
        :count => 1
      }.to_json)

      expect(zendesk.active_incidents.map(&:description)).to eq(['A description'])
      expect(zendesk.active_incidents.map(&:id)).to eq([1234])
    end
  end
end
