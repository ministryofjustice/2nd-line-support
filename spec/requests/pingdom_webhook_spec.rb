require 'spec_helper'
require_relative 'shared_examples/up_and_down_messages'

describe 'GET /pingdom_webhook' do
  context 'when message query parameter is not present' do
    before do
      get '/pingdom_webhook'
    end

    it 'returns 400 error' do
      expect(last_response).to be_bad_request
    end
  end

  context 'when message query parameter is present' do
    let(:service_id) { 'awesome service' }
    let(:existing_alert_key) { 'pingdom:existing' }
    let(:new_alert_key) { 'pingdom:new' }
    let(:new_alert_message) { 'DESCRIPTION' }

    before do
      Alert.create(existing_alert_key, 'some data')

      get "/pingdom_webhook?message=#{message}"
    end

    context 'for an invalid message' do
      let(:message) { 'INVALID' }
      it 'returns 422 error' do
        expect(last_response).to be_unprocessable
      end
    end

    context 'for a valid message - new format' do
      let(:message) { %({"check": "", "checkname": "#{service_id}", "action": "#{action}", "incidentid": "", "description": "#{new_alert_message}"}) }

      context 'when action is "assign"' do
        let(:action) { 'assign' }
        let(:service_id) { 'new' }

        include_examples 'for down message'
      end

      context 'when action is "notify_of_close"' do
        let(:action) { 'notify_of_close' }
        let(:service_id) { 'existing' }

        include_examples 'for up message'
      end
    end

    context 'for a valid message - old format' do
      let(:message) { %(PingdomAlert #{action}: some.service.url (#{service_id}) #{new_alert_message}) }

      context 'when action is "assign"' do
        let(:action) { 'DOWN' }
        let(:service_id) { 'new' }

        include_examples 'for down message'
      end

      context 'when action is "notify_of_close"' do
        let(:action) { 'UP' }
        let(:service_id) { 'existing' }

        include_examples 'for up message'
      end
    end

  end
end