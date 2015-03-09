require 'spec_helper'

describe 'GET /pingdom_notify/:service_id' do
  def app
    SupportApp
  end

  context 'when message query parameter is not present' do
    before do
      get '/pingdom_notify/awesome-service'
    end

    it 'returns 400 error' do
      expect(last_response).to be_bad_request
    end
  end

  context 'when message query parameter is present' do
    let(:service_id) { 'awesome-service' }
    let(:existing_alert_key) { 'pingdom/existing' }
    let(:new_alert_key) { 'pingdom/new' }

    before do
      Alert.create(existing_alert_key, 'some data')

      get "/pingdom_notify/#{service_id}?message=#{message}"
    end

    context 'for an invalid message' do
      let(:message) { 'INVALID' }
      it 'returns 422 error' do
        expect(last_response).to be_unprocessable
      end
    end

    context 'for a valid message - json' do
      let(:message) { '{"check": "", "action": "' + action + '", "incidentid": "", "description": "DESCRIPTION"}' }

      context 'when action is "assign"' do
        let(:action) { 'assign' }
        let(:service_id) { 'new' }

        it 'creates a new alert' do
          expect(Alert.exists?(existing_alert_key)).to be true
        end

        it 'the alert contains message identifying the problem with the service' do
          expect(Alert.fetch(new_alert_key).message).to eql("#{service_id}: DESCRIPTION")
        end

        it 'returns 200 success' do
          expect(last_response).to be_ok
        end
      end

      context 'when action is "notify_of_close"' do
        let(:action) { 'notify_of_close' }
        let(:service_id) { 'existing' }

        it 'removes the existing alert' do
          expect(Alert.exists?(existing_alert_key)).to be false
        end

        it 'returns 200 success' do
          expect(last_response).to be_ok
        end
      end
    end
  end
end