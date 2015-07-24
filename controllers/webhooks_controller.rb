require_relative '../services/hipchat_webhook'

class SupportApp < Sinatra::Application
  post '/hipchat_webhook' do
    if params.has_key?('room')
      webhook_processor = HipchatWebhook.new(params)
      webhook_processor.process ? 200 : 204
    else
      400
    end
  end
end
