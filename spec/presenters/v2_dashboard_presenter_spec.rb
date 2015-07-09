require 'spec_helper'


describe V2DashboardPresenter do

  let(:presenter)         { V2DashboardPresenter.new }
  let(:data)              { presenter.instance_variable_get(:@data) }
  let(:duty_roster_data)  { data['duty_roster'] }
  let(:irm_hash)          { data[]}
  let(:redis_client)      { RedisClient.instance }


  describe '#to_json' do
    it 'should call the read methods and then return @ data as json' do
      expect(presenter).to receive(:initialize_data_for_internal_view)
      expect(presenter).to receive(:read_duty_roster_data)
      expect(presenter).to receive(:read_pagerduty_alerts)
      expect(presenter).to receive(:read_zendesk_tickets)
      presenter.instance_variable_set(:@data, expected_duty_roster)
      expect(presenter.to_json).to eq expected_duty_roster.to_json
    end
  end


  describe '#external' do
    it 'should return an hash of IRM and tickets only' do
      expect(redis_client).to receive(:get).with('duty_roster:v2irm').and_return( { 'name' => 'Kamala Hamilton-Brown', 'telephone' => '7958512425' } )
      expect(redis_client).to receive(:get).with('zendesk:tickets').and_return( [] )

      expect(presenter.external).to eq ( {"duty_roster"=>[{"name"=>"Kamala Hamilton-Brown", "role"=>"irm", "telephone"=>"7958512425"}], "tickets"=>[]} )
    end
  end


  describe 'read_zendesk_tickets' do
    
    before(:each) do
      redis_client.set('zendesk:incidents_in_last_week', 42)
    end

    context 'no open incidents and three in last week' do
      it 'should create an empty array of tickets and black status bar' do
        redis_client.set('zendesk:tickets', [] )
        presenter.send(:initialize_data_for_internal_view)
        presenter.send(:read_zendesk_tickets)
        
        data =  presenter.instance_variable_get(:@data)
        expect(data['tickets']).to be_empty
        expect(data['status_bar_text']).to eq "42 incidents in the past week"
        expect(data['status_bar_status']).to eq "ok"
      end
    end

    context '3 open tickets, none of them problems' do
      it 'should add the array of tickets to data and color the status bar amber' do
        redis_client.set('zendesk:tickets', three_open_zendesk_incidents )
        presenter.send(:read_zendesk_tickets)
        
        data =  presenter.instance_variable_get(:@data)
        expect(data['tickets']).to eq three_open_zendesk_incidents
        expect(data['status_bar_text']).to eq "42 incidents in the past week"
        expect(data['status_bar_status']).to eq "warn"
      end
    end
  end


  describe 'read_pagerduty_alerts' do
    context 'three alerts' do
      it 'should populate number of alerts with 3' do
        redis_client.set('alert:pagerduty:ABC123', "Very bad problem" )
        redis_client.set('alert:pagerduty:XYZ124', "Serious issues" )
        redis_client.set('alert:pagerduty:HRD41D', "My first car" )
        
        presenter.send(:read_pagerduty_alerts)
        data = presenter.instance_variable_get(:@data)
        expect(data['number_of_alerts']).to eq 3
      end
    end

    context 'no alerts' do
      it 'should populate number of alerts with zero' do
        presenter.send(:read_pagerduty_alerts)
        data = presenter.instance_variable_get(:@data)
        expect(data['number_of_alerts']).to eq 0
      end
    end
  end


  describe 'read_duty_roster_data'  do
    it 'should format the duty_roster hash with results from redis' do
      redis_client.set('duty_roster:v2members', {"web_ops"=>"Peter Idah", "dev_1"=>"Max Froumentin", "dev_2"=>"Stephen Richards"} )
      redis_client.set('ooh:members', ooh_members)
      redis_client.set('duty_roster:v2irm', { 'name' => 'Kamala Hamilton-Brown', 'telephone' => '7958512425' } )
      
      presenter.send(:initialize_data_for_internal_view)
      presenter.send(:read_duty_roster_data)
      data = presenter.instance_variable_get(:@data)
      expect(data['duty_roster']).to eq( expected_duty_roster )
    end
  end
end

def ooh_members
  [
    {"name"=>"Steve Marshall", "rule"=>"webop", "has_phone"=>true},
    {"name"=>"Ash Berlin", "rule"=>"dev", "has_phone"=>true}
  ]
end



def three_open_zendesk_incidents
  [
    {
      'type' => 'incident',
      'ticket_no' => 8307,
      'text' =>  'Descriptin of ticket 8307'
    },
    {
      'type' => 'incident',
      'ticket_no' => 7415,
      'text' =>  'Descriptin of ticket 7415'
    },
    {
      'type' => 'incident',
      'ticket_no' => 7855,
      'text' =>  'Descriptin of ticket 7855'
    }       
  ]
end

def expected_duty_roster
  [
    { 'name' => 'Peter Idah',             'role' => 'web_ops' },
    { 'name' => 'Max Froumentin',         'role' => 'dev_1' },
    { 'name' => 'Stephen Richards',       'role' => 'dev_2' },
    { 'name' => 'Kamala Hamilton-Brown',  'role' => 'irm',      'telephone' => '7958512425'},
    { 'name' => 'Steve Marshall',         'role' => 'ooh_1' },
    { 'name' => 'Ash Berlin',             'role' => 'ooh_2' }
    
  ]
end


def redis_irm_hash
  {
    "name"=>"Kamala Hamilton-Brown", 
    "telephone"=>"8958551905"
  }
end