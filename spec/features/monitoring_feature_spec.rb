require 'spec_helper'

describe 'App monitoring', :type => :feature do
  context 'ping.json' do
    let(:result) { { commit: 1, update_time: 2, version: 3 } }

    before(:each) do
      allow(DeploymentInfo).to receive(:latest).and_return(result)
    end

    it '/ping.json should display app version and last update time' do
      visit '/ping.json'

      expect(page).to have_content(
        "{\"status\":200,\"data\":{\"commit\":1,\"update_time\":2,\"version\":3}}"
      )
    end
  end

  context 'healthcheck.json' do
    before(:each) do
      allow_any_instance_of(HealthCheck::GoogleDocs)
        .to receive(:accessible?).and_return(true)

      allow_any_instance_of(HealthCheck::PagerdutyApi)
        .to receive(:accessible?).and_return(true)

      allow_any_instance_of(HealthCheck::ZendeskApi)
        .to receive(:accessible?).and_return(true)
    end

    it 'should display the status of the application components' do
      basic_auth
      visit '/healthcheck.json'

      expect(page).to have_content(
        "{\"status\":\"200\",\"messages\":\"All Components OK\"}"
      )
    end
  end
end