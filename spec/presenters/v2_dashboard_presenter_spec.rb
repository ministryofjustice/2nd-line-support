require 'spec_helper'


describe V2DashboardPresenter do

  let(:presenter)         { V2DashboardPresenter.new }
  let(:data)              { presenter.instance_variable_get(:@data) }
  let(:duty_roster_data)  { data['duty_roster'] }
  let(:irm_hash)          { data[]}
  let(:redis_client)      { RedisClient.instance }


  describe '#to_json' do
    it 'should call the collect methods and then return @ data as json' do
      expect(presenter).to receive(:collect_duty_roster_data)
      expect(presenter).to receive(:collect_irm)
      presenter.instance_variable_set(:@data, expected_duty_roster)
      expect(presenter.to_json).to eq expected_duty_roster.to_json
    end
  end



  describe 'collect_duty_roster_data'  do
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

      presenter.send(:collect_duty_roster_data)
      expect(duty_roster_data).to eq expected_duty_roster
    end
  end


  describe 'collect_irm' do
    it 'should format the IRM details it gets from redis' do
      expect(redis_client).to receive(:get).with('duty_roster:v2irm').and_return(redis_irm_hash)
      presenter.send(:collect_irm)
      expect(duty_roster_data['irm']).to eq 'Kamala Hamilton-Brown'
      expect(duty_roster_data['irm_telephone']).to eq '8958551905'
    end
  end

  
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