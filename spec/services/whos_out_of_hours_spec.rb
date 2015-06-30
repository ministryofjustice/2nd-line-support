require 'spec_helper'
require 'services/whos_out_of_hours'
require 'services/ir_pagerduty'
require 'support/request_handlers'

describe WhosOutOfHours do
  include RequestHandlers
  
  let(:out_of_hours_sid) { SupportApp.pager_duty_schedule_ids.split(',').first    }
  let(:schedule)         { "{\"users\":[{\"name\":\"Stuart Munro\"}]}"            }
  let(:schedule2)        { "{\"users\":[{\"name\":\"Mateusz Lapsa-Malawski\"}]}"  }
  let(:pagerduty)        { IRPagerduty.new                                        }
  
  describe '.pagerduty_names' do
    context "when no one on duty" do
      it "returns empty array" do
        pagerduty_schedule_api_returns(nil)
        expect(pagerduty.fetch_todays_schedules_names(out_of_hours_sid)).to eql([])
      end
    end

    context "when person(s) on duty" do
      it 'returns array of names' do
        pagerduty_schedule_api_returns(schedule)
        expect(pagerduty.fetch_todays_schedules_names(out_of_hours_sid)).to eql(["Stuart Munro"])
      end
    end
  end

  describe '.list' do
    before do
      pagerduty_schedule_api_returns(schedule)
    end

    it 'returns "persons" hash' do
      expect(WhosOutOfHours.list.first.keys).to eql([:name, :rule, :has_phone])
    end

    it 'returns first schedule person as primary (webop)' do
      expect(WhosOutOfHours.list[0].values).to eql(["Stuart Munro", "webop", true])
    end

    it 'returns second schedule person as secondary (dev)' do
      pagerduty_schedule_api_returns(schedule2)
      expect(WhosOutOfHours.list[1].values).to eql(["Mateusz Lapsa-Malawski", "dev", true])
    end
  end
end
