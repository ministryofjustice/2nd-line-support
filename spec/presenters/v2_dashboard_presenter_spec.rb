require 'spec_helper'


describe V2DashboardPresenter do

  let(:presenter)         { V2DashboardPresenter.new }
  let(:data)              { presenter.instance_variable_get(:@data) }
  let(:duty_roster_data)  { data['duty_roster'] }
  let(:irm_hash)          { data[]}
  let(:redis_client)      { RedisClient.instance }


  describe '#to_json' do
    it 'should call the read methods and then return @ data as json' do
      expect(presenter).to receive(:read_duty_roster_data)
      expect(presenter).to receive(:read_irm)
      expect(presenter).to receive(:read_pagerduty_alerts)
      expect(presenter).to receive(:read_zendesk_tickets)
      presenter.instance_variable_set(:@data, expected_duty_roster)
      expect(presenter.to_json).to eq expected_duty_roster.to_json
    end
  end


  describe 'read_zendesk_tickets' do
    
    before(:each) do
      redis_client.set('zendesk:incidents_in_last_week', 42)
    end

    context 'no open incidents and three in last week' do
      it 'should create an empty array of tickets and black status bar' do
        redis_client.set('zendesk:tickets', [] )
        presenter.send(:read_zendesk_tickets)
        
        data =  presenter.instance_variable_get(:@data)
        expect(data['tickets']).to be_empty
        expect(data['status_bar_text']).to eq "42 incidents in the past week"
        expect(data['status_bar_color']).to eq "black"
      end
    end

    context '3 open tickets, none of them problems' do
      it 'should add the array of tickets to data and color the status bar amber' do
        redis_client.set('zendesk:tickets', three_open_zendesk_incidents )
        presenter.send(:read_zendesk_tickets)
        
        data =  presenter.instance_variable_get(:@data)
        expect(data['tickets']).to eq three_open_zendesk_incidents
        expect(data['status_bar_text']).to eq "42 incidents in the past week"
        expect(data['status_bar_color']).to eq "amber"
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
    it 'should format the duty_roster hash with results from DutyRosterMembers' do
      duty_roster_hash = {:web_ops=>"Peter Idah", :dev_1=>"Max Froumentin", :dev_2=>"Stephen Richards"} 
      ooh_hash = [
        {
          "name"=>"Steve Marshall", 
          "rule"=>"webop", 
          "has_phone"=>true}, 
        {
          "name"=>"Ash Berlin", 
          "rule"=>"dev", 
          "has_phone"=>true}
      ]
      expect(DutyRosterMembers).to receive(:v2_list).and_return(duty_roster_hash)
      expect(redis_client).to receive(:get).with('ooh:members').and_return(ooh_hash)

      presenter.send(:read_duty_roster_data)
      expect(duty_roster_data).to eq expected_duty_roster
    end
  end


  describe 'read_irm' do
    it 'should format the IRM details it gets from redis' do
      expect(redis_client).to receive(:get).with('duty_roster:v2irm').and_return(redis_irm_hash)
      presenter.send(:read_irm)
      expect(duty_roster_data['irm']).to eq 'Kamala Hamilton-Brown'
      expect(duty_roster_data['irm_telephone']).to eq '8958551905'
    end
  end

  
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
  {
    :web_ops=>"Peter Idah", 
    :dev_1=>"Max Froumentin", 
    :dev_2=>"Stephen Richards", 
    "ooh_1"=>"Steve Marshall", 
    "ooh_2"=>"Ash Berlin"
  }
end


def redis_irm_hash
  {
    "name"=>"Kamala Hamilton-Brown", 
    "telephone"=>"8958551905"
  }
end