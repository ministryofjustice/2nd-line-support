require 'spec_helper'

require 'services/sensu_webhook'

describe SensuWebhook do
  let(:service_id) { 'SOME_SERVICE' }
  let(:service_alert_key) { "#{described_class::REDIS_KEY_PREFIX}:#{service_id}"}

  describe '#process' do
    subject { described_class.new(payload).process }

    context 'for "create" action' do
      let(:payload) do
        {
            'key' => service_id,
            'event' => {
                'check' => {
                    'output' => 'MESSAGE'
                },
                'action' => 'create'
            }
        }
      end

      it { is_expected.to be true }

      it 'creates a new alert for the service' do
        subject

        expect(Alert.exists?(service_alert_key)).to be true
      end
    end

    context 'for "resolve" action' do
      let(:payload) do
        {
            'key' => service_id,
            'event' => {
                'action' => 'resolve'
            }
        }
      end

      it { is_expected.to be true }

      it 'removes the existing alert' do
        subject

        expect(Alert.exists?(service_alert_key)).to be false
      end
    end
  end
end