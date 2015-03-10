require 'spec_helper'

require 'services/pingdom_webhook'

describe PingdomWebhook do
  let(:service_id) { 'SOME_SERVICE' }
  let(:service_alert_key) { "#{described_class::REDIS_KEY_PREFIX}/#{service_id}"}

  subject(:pingdom_web_hook) { described_class.new(service_id) }

  describe '#process' do
    subject { pingdom_web_hook.process(message) }

    context 'for invalid message' do
      let(:message) { 'INVALID' }

      it { is_expected.to be false }
    end
    context 'for message with "assign" action' do
      let(:message) { '{"check": "", "action": "assign", "incidentid": "", "description": ""}' }

      it { is_expected.to be true }

      it 'creates a new alert for the service' do
        subject

        expect(Alert.exists?(service_alert_key)).to be true
      end
    end
    context 'for message with "notify_of_close" action' do
      let(:message) { '{"check": "", "action": "notify_of_close", "incidentid": "", "description": ""}' }

      before do
        Alert.create(service_alert_key, '{}')
      end

      it { is_expected.to be true }

      it 'removes the existing alert' do
        subject

        expect(Alert.exists?(service_alert_key)).to be false
      end
    end
  end
end