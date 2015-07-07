require 'spec_helper'
require_relative '../../services/event_collector'

describe EventCollector do

  let(:redis)                   { RedisClient.instance }
  let(:duty_roster_double)      { double DutyRoster }
  let(:collector)               { EventCollector.new }
  let(:pagerduty)               { double IRPagerduty }

  before(:each) do
    expect(DutyRoster).to receive(:default).and_return(duty_roster_double)
  end

  describe '.run' do
    it 'should call all of the store methods' do
      expect(duty_roster_double).to receive(:update)

      expect(collector).to receive(:store_out_of_hours)
      expect(collector).to receive(:store_irm)

      collector.run
    end
  end


  describe '.store_out_of_hours' do
    it 'should store the WhosOutOfHours list in redis' do
      expect(WhosOutOfHours).to receive(:list).and_return('List of staff members on duty out of hours')
      expect(redis).to receive(:set).with('ooh:members', 'List of staff members on duty out of hours')
      collector.send(:store_out_of_hours)
    end
  end


  describe '. store_irm' do
    it 'should store user details for the layer 2 schedule for incident response manager' do
      expect(IRPagerDuty).to receive(:new).and_return(pagerduty)
      expect(pagerduty).to receive(:fetch_irm).and_return(irm_schedules)
      expect(pagerduty).to receive(:fetch_todays_schedules_users).and_return(pager_duty_users)
      collector.send(:store_irm)
    end
  end
end



def irm_schedules
  {
    'schedule' => {
      'schedule_layers' => [
        {
          'name' => 'Layer 1',
          'users' => layer_n_users(1)
        },
        {
          'name' => 'Layer 2',
          'users' => layer_n_users(2)
        },
      ]
    }
  }
end

def layer_n_users(n)
  [
   {
      "user" => {
        "id" => "LAYER#{n}-USER1",
        "name" => "Layer #{n} - user 1",
      }
   },
   {
      "user" => {
        "id" => "LAYER#{n}-USER2",
        "name" => "Layer #{n} - user 2",
      }
   }
  ]
end
