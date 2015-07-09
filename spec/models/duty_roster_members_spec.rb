require 'spec_helper'


describe DutyRosterMembers do



  describe '.v2_list' do

    let(:redis_client)      { RedisClient.instance }
    let(:members_hash)      { { 'dev_1' => 'Jow Blow', 'web_ops' => 'Mary Smith', 'dev_2' => 'John Smith'} }
    let(:result_hash)       { { :dev_1 => 'Jow Blow', :web_ops => 'Mary Smith', :dev_2 => 'John Smith'} }

    it 'should return the values in the redis database for key duty-roster:v2members' do
      RedisClient.instance.set('duty_roster:v2members', members_hash)
      expect(DutyRosterMembers.v2_list).to eq result_hash
    end
  end
  
  describe '.format_data_for_v2' do
    it 'should extract devs and webops and format into a hash' do
      expected_data = {
        'web_ops' => 'Alistair Davidson',
        'dev_1'   => 'Max Froumentin',
        'dev_2'   => 'Stephen Richards',
        'dev_3'   => 'Eddie'
      }
      expect(DutyRosterMembers.format_data_for_v2(v1_data)).to eq expected_data
    end
  end
end


def v1_data
  [
    {
      :name=>"Alistair Davidson",
      :rule=>"webop",
      :has_phone=>true,
      :contact_methods=>[]
    },
    {
      :name=>"Max Froumentin",
      :rule=>"dev",
      :has_phone=>true,
      :contact_methods=>[]
    },
    {
      :name=>"Stephen Richards",
      :rule=>"dev",
      :has_phone=>false,
      :contact_methods=>[]
    },
    {
      :name=>"Eddie", 
      :rule=>"dev", 
      :has_phone=>false, 
      :contact_methods=>[]
    },
    {
      :name=>"Mark Stanley",
      :rule=>"duty_manager",
      :has_phone=>false,
      :contact_methods=>[
        {
          :type=>"email",
          :address=>"mark.stanley@digital.justice.gov.uk",
          :label=>"Default"
        },
        {
          :type=>"phone", 
          :address=>"(00) 44 78 3330 5595", 
          :label=>"Work"
        }
      ]
      },
      {
        :name=>"Jake Barlow",
        :rule=>"duty_manager",
        :has_phone=>false,
        :contact_methods=>[
          {
            :type=>"email",
            :address=>"jake.barlow@digital.justice.gov.uk",
            :label=>"Default"
          },
          {
            :type=>"phone", 
            :address=>"(00) 44 77 6833 8182", 
            :label=>"Mobile"
          }
        ]
      }
    ]
end