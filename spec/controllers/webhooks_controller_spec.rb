require 'spec_helper'


describe 'webhooks_cotroller' do
  include Rack::Test::Methods

  def app
    SupportApp
  end

  context 'with a room parameter' do
    it "calls the hipchat webhook and returns 200 if success" do
      params                 = {'room' => '2nd_line_support', 'message' => 'problem off'}
      hipchat_webhook_double = double HipchatWebhook

      expect(HipchatWebhook).to receive(:new).with(params).and_return(hipchat_webhook_double)
      expect(hipchat_webhook_double).to receive(:process).and_return(true)

      post '/hipchat_webhook', params
      expect(last_response).to be_ok
    end
  end

  context 'without a room parameter' do
    it 'should return 400' do
      params                 = {'message' => 'problem off'}
      hipchat_webhook_double = double HipchatWebhook

      post '/hipchat_webhook', params
      expect(last_response.status).to eq 400
    end
  end


end
