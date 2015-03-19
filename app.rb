$: << File.expand_path('..', __FILE__)

require 'rubygems'
require 'sinatra'
require 'excon'
Excon.defaults[:middlewares] << Excon::Middleware::RedirectFollower
require_relative 'models/alert.rb'
require_relative 'models/traffic_spike.rb'
require_relative 'lib/real_time_analytics.rb'
require_relative 'services/pingdom_webhook'
require_relative 'services/sensu_webhook'
require_relative 'services/whos_on_duty'

class SupportApp < Sinatra::Application
  get '/pingdom_webhook' do
    if params.has_key?('message')
      webhook_processor = PingdomWebhook.new(params['message'])
      webhook_processor.process ? 200 : 422
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
    @whos_on_duty = WhosOnDuty.list
    erb :index
  end
end