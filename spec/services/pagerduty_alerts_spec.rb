require 'spec_helper'

require 'services/pagerduty_alerts'
require 'support/request_handlers'

describe PagerDutyAlerts do
  include RequestHandlers

  let(:alert_key) { "#{described_class::REDIS_KEY_PREFIX}:alert-id"}

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
        pagerduty_incidents_api_returns(body)
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

        pagerduty_incidents_api_returns(body)
        subject

        expect(Alert.exists?(alert_key)).to be false
      end
    end
  end
end
