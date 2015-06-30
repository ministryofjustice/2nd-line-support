require 'json'
require 'spec_helper'

require 'services/zendesk'

describe Presenters::Dashboard do
  def mock_zendesk_response(body)
    stub_request(
      :get,
      /https:\/\/.*@ministryofjustice\.zendesk\.com\/api\/v2\/.*/
    ).to_return(
      :status => 200,
      :headers => {
        "Content-Type" => "application/json"
      },
      :body => body
    )
  end

  let(:duty_roster)         { OpenStruct.new(:members => ['a', 'b', 'c'] ) }

  before(:each) do
    allow_any_instance_of(WhosOutOfHours).to receive(:list).and_return(['x', 'y', 'z'])
  end



  context 'incidents in last week' do
    context 'when no incidents have occurred' do
      it 'should return 0' do
        mock_zendesk_response({
          :results => [],
          :facets => nil,
          :next_page => nil,
          :previous_page => nil,
          :count => 0
        }.to_json)

        result_set = Presenters::Dashboard.admin(duty_roster)
        expect(result_set.incidents_in_past_week).to eq 0
      end
    end

    context 'when the number of incidents increases between calls' do
      it 'should return 1 the first time and 3 the second time' do
        mock_zendesk_response({
          :results => [ {} ],
          :facets => nil,
          :next_page => nil,
          :previous_page => nil,
          :count => 1
        }.to_json)

        result_set = Presenters::Dashboard.admin(duty_roster)
        expect(result_set.incidents_in_past_week).to eq 1

        mock_zendesk_response({
          :results => [ {}, {}, {} ],
          :facets => nil,
          :next_page => nil,
          :previous_page => nil,
          :count => 3
        }.to_json)

        result_set = Presenters::Dashboard.admin(duty_roster)
        expect(result_set.incidents_in_past_week).to eq 3

      end
    end
  end
end
