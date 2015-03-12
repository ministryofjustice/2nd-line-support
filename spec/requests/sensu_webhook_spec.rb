require 'spec_helper'
require_relative 'shared_examples/up_and_down_messages'

describe 'POST /sensu_webhook' do
  let(:existing_alert_key) { 'sensu/existing' }
  let(:new_alert_key) { 'sensu/new' }
  let(:new_alert_message) { 'DESCRIPTION' }

  before do
    Alert.create(existing_alert_key, 'some data')

    post '/sensu_webhook', payload: payload
  end

  subject { last_response }

  context 'without a payload' do
    let(:payload) { {} }
    it 'returns 400 error' do
      is_expected.to be_bad_request
    end
  end

  context 'for "create" event' do
    let(:payload) do
      {
          'key' => service_id,
          'event' => {
              'check' => {
                  'output' => new_alert_message
              },
              'action' => 'create'
          }
      }
    end
    let(:service_id) { 'new' }

    include_examples 'for down message'
  end

  context 'for "resolve" event' do
    let(:payload) do
      {
          'key' => service_id,
          'event' => {
              'action' => 'resolve'
          }
      }
    end
    let(:service_id) { 'existing' }

    include_examples 'for up message'
  end
end