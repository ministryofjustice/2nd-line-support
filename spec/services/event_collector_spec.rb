require 'spec_helper'
require_relative '../../services/event_collector'
require_relative '../../services/ir_pagerduty'

describe EventCollector do

  let(:redis)                   { RedisClient.instance }
  let(:duty_roster_double)      { double DutyRoster }
  let(:collector)               { EventCollector.new }
  let(:pagerduty)               { double IRPagerduty }


  describe '.run' do
    it 'should call all of the store methods' do
      expect(DutyRoster).to receive(:default).and_return(duty_roster_double)
      expect(duty_roster_double).to receive(:update)

      expect(collector).to receive(:store_out_of_hours)
      expect(collector).to receive(:store_irm)
      expect(collector).to receive(:store_pagerduty_alerts)

      collector.run
    end
  end

  describe '.store_pagerduty_alerts' do
    it 'should call check alerts on PagerDutyAlerts' do
      pda_double = double PagerDutyAlerts
      expect(PagerDutyAlerts).to receive(:new).and_return(pda_double)
      expect(pda_double).to receive(:check_alerts)

      collector.send(:store_pagerduty_alerts)
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
      expect(IRPagerduty).to receive(:new).and_return(pagerduty)
      expect(pagerduty).to receive(:fetch_irm).and_return(irm_schedules)
      allow(pagerduty).to receive(:fetch_todays_schedules_users).and_return(pagerduty_users)
      expect(redis).to receive(:set).with('duty_roster:v2irm', {"name"=>"layer 2 user", "telephone"=>"7590483002"})
      
      collector.send(:store_irm)
    end
  end
end


def pagerduty_users
  [
    {
      'id' => 'ABC123',
      'name' => 'Dummy user',
      'contact_methods' => [
          {
            'type' => 'phone',
            'address' => '7590483002'
          },
          { 
            'type' => 'email',
            'address' => 'me@example.com'
          }
      ]
    },
    {
      'id' => 'LAYER2-USER1',
      'name' => 'layer 2 user',
      'contact_methods' => [
          {
            'type' => 'phone',
            'address' => '7590483002'
          },
          { 
            'type' => 'email',
            'address' => 'me@example.com'
          }
      ]
    }
  ]
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
