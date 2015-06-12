require 'json'
require 'spec_helper'

require 'services/zendesk'

describe Zendesk do

  let(:zendesk) { Zendesk.new }

  describe '#incidents_for_the_past_week' do

    def mock_zendesk_response(body)
      stub_request(
        :get,
        /.*zendesk.com\/api\/v2\/.*/
      ).with(
        :body => "{\"query\":\"query:created>7days group:\\\"Incident response and tuning\\\" type:ticket\"}"
      ).to_return(:status => 200, :body => body, :headers => {"Content-Type" => "application/json"})
    end

    context 'when no incidents have occurred' do
      it 'should return 0' do
        mock_zendesk_response({
          :results => [],
          :facets => nil,
          :next_page => nil,
          :previous_page => nil,
          :count => 0
        }.to_json)

        expect(zendesk.incidents_for_the_past_week).to eq(0)
      end
    end

    context 'when 1 incident has occurred' do
      it 'should return 1' do
        mock_zendesk_response({
          :results => [ {} ],
          :facets => nil,
          :next_page => nil,
          :previous_page => nil,
          :count => 1
        }.to_json)

        expect(zendesk.incidents_for_the_past_week).to eq(1)
      end
    end

    context 'when 5 incidents have occurred' do
      it 'should return 5' do
        mock_zendesk_response({
          :results => [ {}, {}, {}, {}, {} ],
          :facets => nil,
          :next_page => nil,
          :previous_page => nil,
          :count => 5
        }.to_json)

        expect(zendesk.incidents_for_the_past_week).to eq(5)
      end
    end

  end

end
