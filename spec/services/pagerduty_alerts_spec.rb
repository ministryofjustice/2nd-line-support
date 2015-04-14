require 'spec_helper'

require 'services/pagerduty_alerts'

describe PagerDutyAlerts do
  let(:alert_key) { "#{described_class::REDIS_KEY_PREFIX}:alert-id"}

  let(:successful_request_stub) { 
    stub_request(
          :get, 
          "https://moj.pagerduty.com/api/v1/incidents?service=service1,service2&status=triggered,acknowledged"
        ).with(
          :headers => {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization'=>'Token token=testing_token',
            'Content-Type'=>'application/json',
            'User-Agent'=>'Ruby'
          }
        ).to_return(:status => 200, :body => body, :headers => {})
  }


  describe '#check_alerts' do
    subject { described_class.new().check_alerts }

    context 'when incidents exist' do
      let(:body) do
        {
            "incidents": [
            {
              "id": "alert-id",
              "service": {
                  "deleted_at": nil,
                  "id": "service1",
                  "name": "Service 1"
              },
              "status": "triggered",
              "trigger_summary_data": {
                  "description": "Problem!"
              },
            }],
            "limit": 100,
            "offset": 0,
            "total": 17
        }.to_json
      end


      it 'processes alerts from pagerduty' do
        described_class.new().reset_check
        successful_request_stub
        subject

        expect(Alert.exists?(alert_key)).to be true
      end
    end

    context 'when incidents get resolved' do
      let(:body) do
        {
            "incidents": [],
            "limit": 100,
            "offset": 0,
            "total": 17
        }.to_json
      end

      it 'processes alerts from pagerduty' do
        described_class.new().reset_check
        Alert.create(alert_key, 'body')

        expect(Alert.exists?(alert_key)).to be true

        successful_request_stub
        subject

        expect(Alert.exists?(alert_key)).to be false
      end
    end
  end
end
