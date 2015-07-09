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
      expect(collector).to receive(:store_zendesk_tickets)

      collector.run
    end
  end


  describe '.store_zendesk_tickets' do
    let(:zendesk)           { double Zendesk }



    it 'should retrieve incidents from zendesk and store summary in redis' do
      ticket_1 = double 'ZendeskAPI::Ticket'
      allow(ticket_1).to receive(:id).and_return(1111)
      allow(ticket_1).to receive(:type).and_return('incident')
      allow(ticket_1).to receive(:subject).and_return('First Zendesk Ticket')

      ticket_2 = double 'ZendeskAPI::Ticket'
      allow(ticket_2).to receive(:id).and_return(2222)
      allow(ticket_2).to receive(:type).and_return('problem')
      allow(ticket_2).to receive(:subject).and_return('Second Zendesk Ticket')

      zendesk_collection = [ ticket_1, ticket_2 ]
      expect(Zendesk).to receive(:new).and_return(zendesk)
      expect(zendesk).to receive(:active_incidents).and_return(zendesk_collection)
      expect(zendesk).to receive(:incidents_for_the_past_week).and_return(3)

      expect(redis).to receive(:set).with('zendesk:tickets', ticket_summaries)
      expect(redis).to receive(:set).with('zendesk:incidents_in_last_week', 3)
      collector.send(:store_zendesk_tickets)
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


def ticket_summaries
  [ 
    {
      'ticket_no' => 1111, 
      'type' => 'incident',
      'text' => 'First Zendesk Ticket'
    },
    {
      'ticket_no' => 2222, 
      'type' => 'problem',
      'text' => 'Second Zendesk Ticket'
    }
  ]
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
