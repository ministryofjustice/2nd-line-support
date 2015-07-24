require 'spec_helper'

describe DeploymentInfo do 

  describe '.latest' do
    it 'should return info for the latest deployment' do
      heroku_double = double Heroku::API
      api_response  = double 'Heroku::Api response'
      response_body = {:body => [ {}, {}, {'commit' => '666', 'created_at' => '02/07/2015T15:35:42', 'name' => 'version_name'} ] }
      
      expect(DeploymentInfo).to receive(:heroku).and_return(heroku_double)
      expect(heroku_double).to receive(:get_releases).with(SupportApp.heroku_name).and_return(api_response)  
      expect(api_response).to receive(:data).and_return(response_body)

      expected_result = {
                 :commit => "666",
            :update_time => Time.new(2015, 7, 2, 15, 35, 42),
                :version => "version_name"
        }

      expect(DeploymentInfo.latest).to eq expected_result
    end
  end
  
end
