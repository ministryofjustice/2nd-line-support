require 'json'
require 'spec_helper'

require 'services/zendesk'
require 'support/request_handlers'


describe Presenters::Dashboard do
  include RequestHandlers

  let(:duty_roster) { OpenStruct.new(:members => ['a', 'b', 'c'] ) }

  before(:each) do
    allow_any_instance_of(WhosOutOfHours)
      .to receive(:list).and_return(['x', 'y', 'z'])
  end

  context 'incidents in last week' do
    context 'when no incidents have occurred' do
      it 'should return 0' do
        zendesk_api_returns(empty_incidents(0))

        result_set = Presenters::Dashboard.admin(duty_roster)
        expect(result_set.incidents_in_past_week).to eq 0
      end
    end

    context 'when the number of incidents increases between calls' do
      it 'should return 1 the first time and 3 the second time' do
        zendesk_api_returns(empty_incidents(1))
        result_set = Presenters::Dashboard.admin(duty_roster)
        
        expect(result_set.incidents_in_past_week).to eq 1

        zendesk_api_returns(empty_incidents(3))
        result_set = Presenters::Dashboard.admin(duty_roster)

        expect(result_set.incidents_in_past_week).to eq 3
      end
    end
  end
end
