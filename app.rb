$: << File.expand_path('..', __FILE__)

require 'rubygems'
require 'sinatra'
require_relative 'models/alert.rb'
require_relative 'models/pingdom_api.rb'
require_relative 'models/traffic_spike.rb'
require_relative 'lib/real_time_analytics.rb'

class SupportApp < Sinatra::Application
  post '/notify' do
    PingdomApi.new.notify(params[:payload])
  end

  get '/update_all' do
    TrafficSpike.update
    PingdomApi.new.appsdownredis
    "updated"
  end

  get '/pingdom_notify/:service_id' do
    if params.has_key?('message')
      begin
        json = JSON.parse(params['message'])

        case json['action']
          when 'assign'
            message = "#{params[:service_id]}: #{json['description']}"
            Alert.create("pingdom/#{params[:service_id]}", { message: message} )
            break
          when 'notify_of_close'
            Alert.destroy("pingdom/#{params[:service_id]}")
            break
        end

        200
      rescue
        422
      end
    else
      400
    end
  end

  get '/' do
    @alerts = Alert.fetch_all
    erb :index
  end
end