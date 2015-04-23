require 'spec_helper'

require 'services/whos_out_of_hours'

describe WhosOutOfHours do

  let(:successful_request_schedule_stub) {
    stub_request(
      :get,
       /moj.pagerduty.com/
       ).with(:headers => {
          'Accept'=>'*/*', 
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 
          'Authorization'=>'Token token=testing_token', 
          'Content-Type'=>'application/json', 
          'User-Agent'=>'Ruby'
        }
      ).to_return(:status => 200, :body => body, :headers => {})
  }

  describe 'get_name' do

    context 'there is a pagerduty id' do
      let(:body) do
        {
            "users":[
              {
                "id":"PVF48XN",
                "name":"Mateusz Lapsa-Malawski",
                "email":"mateusz@digital.justice.gov.uk",
                "time_zone":"London",
                "color":"brown",
                "role":"admin",
                "avatar_url":"https://secure.gravatar.com/avatar/aa9794dd4ffd13ba148e028f6d9a6e2b.png?d=mm&r=PG",
                "description":"",
                "user_url":"/users/PVF48XN",
                "invitation_sent":false,
                "marketing_opt_out":true,
                "job_title":""
                }]
                }.to_json
      end
      it 'returns name' do
        successful_request_schedule_stub
        expect(WhosOutOfHours.get_name("testing_id")).to eql("Mateusz Lapsa-Malawski")
      end
    end
  end

  describe 'list' do
    context 'successful list response' do

        let(:body) do
          {
              "users":[
                {
                  "id":"PVF48XN",
                  "name":"Mateusz Lapsa-Malawski",
                  "email":"mateusz@digital.justice.gov.uk",
                  "time_zone":"London",
                  "color":"brown",
                  "role":"admin",
                  "avatar_url":"https://secure.gravatar.com/avatar/aa9794dd4ffd13ba148e028f6d9a6e2b.png?d=mm&r=PG",
                  "description":"",
                  "user_url":"/users/PVF48XN",
                  "invitation_sent":false,
                  "marketing_opt_out":true,
                  "job_title":""
                  }]
                  }.to_json
        end

      it 'returns hash of names' do
        successful_request_schedule_stub
        expect(WhosOutOfHours.list).to eql( [{:person=>"Mateusz Lapsa-Malawski", :rule=>"webop", :has_phone=>true},
         {:person=>"Mateusz Lapsa-Malawski", :rule=>"webop", :has_phone=>true}])
      end
    end

  end
end