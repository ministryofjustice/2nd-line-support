require 'spec_helper'

require 'services/pingdom_webhook'

shared_examples 'for assign/down message' do
  it { is_expected.to be true }

  it 'creates a new alert for the service' do
    subject

    expect(Alert.exists?(service_alert_key)).to be true
  end
end

shared_examples 'for notify_of_close/up message' do
  before do
    Alert.create(service_alert_key, '{}')
  end

  it { is_expected.to be true }

  it 'removes the existing alert' do
    subject

    expect(Alert.exists?(service_alert_key)).to be false
  end
end

describe PingdomWebhook do
  let(:service_id) { 'SOME_SERVICE' }
  let(:service_alert_key) { "#{described_class::REDIS_KEY_PREFIX}:#{service_id}"}

  subject(:pingdom_web_hook) { described_class.new(message) }

  describe '#process' do
    subject { pingdom_web_hook.process }

    context 'for invalid message' do
      let(:message) { 'INVALID' }

      it { is_expected.to be false }
    end

    context 'for new json format' do
      context 'for message with "assign" action' do
        include_examples 'for assign/down message' do
          let(:message) { %({"check": "", "checkname": "#{service_id}", "action": "assign", "incidentid": "", "description": ""}) }
        end
      end
      context 'for message with "notify_of_close" action' do
        include_examples 'for notify_of_close/up message' do
          let(:message) { %({"check": "", "checkname": "#{service_id}", "action": "notify_of_close", "incidentid": "", "description": ""}) }
        end
      end
    end

    context 'for old text format' do
      context 'for DOWN message' do
        include_examples 'for assign/down message' do
          let(:message) { %(PingdomAlert DOWN: some.service (#{service_id}) DESCRIPTION) }
        end
      end

      context 'for UP message' do
        include_examples 'for notify_of_close/up message' do
          let(:message) { %(PingdomAlert UP: some.service (#{service_id}) DESCRIPTION) }
        end
      end
    end
  end
end