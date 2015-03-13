$: << File.expand_path('..', __FILE__)

require 'rubygems'
require 'sinatra'
require_relative 'models/alert.rb'
require_relative 'models/traffic_spike.rb'
require_relative 'lib/real_time_analytics.rb'
require_relative 'services/pingdom_webhook'
require_relative 'services/sensu_webhook'

class SupportApp < Sinatra::Application
  get '/pingdom_webhook/:service_id' do
    if params.has_key?('message')
      webhook_processor = PingdomWebhook.new(params[:service_id])
      webhook_processor.process(params['message']) ? 200 : 422
    else
      400
    end
  end

  post '/sensu_webhook' do
    if params.has_key?('payload')
      webhook_processor = SensuWebhook.new(params['payload'])
      webhook_processor.process

      200
    else
      400
    end
  end

  get '/' do
    @alerts = Alert.fetch_all
    erb :index
  end
end