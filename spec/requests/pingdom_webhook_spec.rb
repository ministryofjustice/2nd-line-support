require 'spec_helper'

shared_examples 'for down message' do
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

shared_examples 'for up message' do
  it 'removes the existing alert' do
    expect(Alert.exists?(existing_alert_key)).to be false
  end

  it 'returns 200 success' do
    expect(last_response).to be_ok
  end
end

describe 'GET /pingdom_webhook/:service_id' do
  def app
    SupportApp
  end

  context 'when message query parameter is not present' do
    before do
      get '/pingdom_webhook/awesome-service'
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

      get "/pingdom_webhook/#{service_id}?message=#{message}"
    end

    context 'for an invalid message' do
      let(:message) { 'INVALID' }
      it 'returns 422 error' do
        expect(last_response).to be_unprocessable
      end
    end

    context 'for a valid message - new format' do
      let(:message) { %({"check": "", "action": "#{action}", "incidentid": "", "description": "DESCRIPTION"}) }

      context 'when action is "assign"' do
        include_examples 'for down message' do
          let(:action) { 'assign' }
          let(:service_id) { 'new' }
        end
      end

      context 'when action is "notify_of_close"' do
        include_examples 'for up message' do
          let(:action) { 'notify_of_close' }
          let(:service_id) { 'existing' }
        end
      end
    end

    context 'for a valid message - old format' do
      let(:message) { %(PingdomAlert #{action}: some.service (DESCRIPTION) is #{action} since 2015-03-10 16:58:19 GMT +0000) }

      context 'when action is "assign"' do
        include_examples 'for down message' do
          let(:action) { 'DOWN' }
          let(:service_id) { 'new' }
        end
      end

      context 'when action is "notify_of_close"' do
        include_examples 'for up message' do
          let(:action) { 'UP' }
          let(:service_id) { 'existing' }
        end
      end
    end

  end
end