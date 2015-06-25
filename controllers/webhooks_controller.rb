require_relative '../services/hipchat_webhook'
require_relative '../services/sensu_webhook'

class SupportApp < Sinatra::Application
  post '/sensu_webhook' do
    if params.has_key?('payload')
      webhook_processor = SensuWebhook.new(params['payload'])
      webhook_processor.process ? 200 : 204
    else
      400
    end
  end

  post '/hipchat_webhook' do
    if params.has_key?('room')
      webhook_processor = HipchatWebhook.new(params)
      webhook_processor.process ? 200 : 204
    else
      400
    end
  end
end