require 'spec_helper'
require_relative '../../lib/health_check/google_docs'
require_relative '../../lib/health_check/pagerduty_api'
require_relative '../../lib/health_check/zendesk_api'

describe 'Health Check Components' do
  context 'Zendesk Api' do
    let(:zen) { HealthCheck::ZendeskApi.new }

    context '#accessible?' do
      def stub_current_user(data_h)
        allow_any_instance_of(ZendeskAPI::Client)
          .to receive(:current_user)
          .and_return(data_h)
      end

      it 'should return true if the service is accessible' do
        stub_current_user({'name' => 'MOJ'})

        expect(zen).to be_accessible
      end

      it 'should return false if the service is inaccessible' do
        stub_current_user(nil)

        expect(zen).not_to be_accessible
      end

       it 'should return false if the service raises an error' do
        allow_any_instance_of(ZendeskAPI::Client)
          .to receive(:current_user)
          .and_raise(StandardError)

          expect(zen).not_to be_accessible
      end
    end

    context '#error_messages' do
      it 'should return error messages' do
        allow_any_instance_of(ZendeskAPI::Client)
          .to receive(:current_user)
          .and_raise(StandardError, 'a message')

        zen.accessible?
        expect(zen.error_messages).to match([/HealthCheck::ZendeskApi Error: a message/])
      end
    end
  end

  context 'Pagerduty Api' do
    let(:pager) { HealthCheck::PagerdutyApi.new }

    context '#accessible?' do
      def stub_active_users(data_h)
        allow_any_instance_of(IRPagerduty)
          .to receive(:fetch_json)
          .and_return(data_h)
      end

      it 'should return true if the service is accessible' do
        stub_active_users({'active_account_users' => 1})

        expect(pager).to be_accessible
      end

      it 'should return false if the service is inaccessible' do
        stub_active_users(nil)

        expect(pager).not_to be_accessible
      end

       it 'should return false if the service raises an error' do
         allow_any_instance_of(IRPagerduty)
          .to receive(:fetch_json)
          .and_raise(StandardError)

        expect(pager).not_to be_accessible
      end
    end
  end

  context 'Google Docs' do
    let(:doc)     { HealthCheck::GoogleDocs.new           }
    let(:res)     { double Net::HTTPResponse, status: 200 }
    let(:bad_res) { double Net::HTTPResponse, status: 503 }

    context '#accessible?' do
      def stub_google_response(res)
        allow(Excon)
          .to receive(:get)
          .and_return(res)
      end

      it 'should return true if the service is accessible' do
        stub_google_response(res)

        expect(doc).to be_accessible
      end

      it 'should return false if the service is inaccessible' do
        stub_google_response(bad_res)

        expect(doc).not_to be_accessible
      end

      it 'should return false if the service raises an error' do
        allow(Excon)
          .to receive(:get)
          .and_raise(StandardError)
        
        expect(doc).not_to be_accessible
      end
    end
  end
end