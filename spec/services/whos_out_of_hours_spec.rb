require 'spec_helper'
require 'services/whos_out_of_hours'
require 'services/ir_pagerduty'

describe WhosOutOfHours do
  let(:out_of_hours_sid) { SupportApp.pager_duty_schedule_ids.split(',').first }

  let(:stub_pagerduty_primary_schedule_api_call) do
    stub_request(
      :get,
       moj_pagerduty_schedule_regex
      ).to_return(:status => 200, :body => { "users": [{ "name": "Stuart Munro" }] }.to_json )
  end

  describe '.pagerduty_names' do
    let(:pagerduty) { IRPagerduty.new }

    context "when no one on duty" do
      let(:stub_pagerduty_schedule_api_call_empty) do
        stub_request(
          :get,
           moj_pagerduty_schedule_regex
          ).to_return(:status => 200, :body => nil)
      end

      it "returns empty array" do
          stub_pagerduty_schedule_api_call_empty
          expect(pagerduty.fetch_todays_schedules_names(out_of_hours_sid)).to eql([])
      end
    end

    context "when person(s) on duty" do
      it 'returns array of names' do
        stub_pagerduty_primary_schedule_api_call
        expect(pagerduty.fetch_todays_schedules_names(out_of_hours_sid)).to eql(["Stuart Munro"])
      end
    end
  end

  describe '.list' do
    let(:stub_pagerduty_secondary_schedule_api_call) do
      stub_request(
        :get,
         moj_pagerduty_schedule_regex
        ).to_return(:status => 200, :body => { "users": [{ "name": "Mateusz Lapsa-Malawski" }] }.to_json) 
    end

    before { stub_pagerduty_primary_schedule_api_call }

    it 'returns "persons" hash' do
      expect(WhosOutOfHours.list.first.keys).to eql([:name, :rule, :has_phone])
    end

    it 'returns first schedule person as primary (webop)' do
      expect(WhosOutOfHours.list[0].values).to eql(["Stuart Munro","webop",true])
    end

    it 'returns second schedule person as secondary (dev)' do
      stub_pagerduty_secondary_schedule_api_call
      expect(WhosOutOfHours.list[1].values).to eql(["Mateusz Lapsa-Malawski","dev",true])
    end
  end
end
