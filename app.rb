$: << File.expand_path("..", __FILE__)

require "rubygems"
require "sinatra"
require_relative "models/alert.rb"
require_relative "models/pingdom_api.rb"
require_relative "models/traffic_spike.rb"
require_relative "lib/real_time_analytics.rb"
require_relative "services/pingdom_webhook"

class SupportApp < Sinatra::Application
  post "/notify" do
    PingdomApi.new.notify(params[:payload])
  end

  get "/update_all" do
    TrafficSpike.update
    PingdomApi.new.appsdownredis
    "updated"
  end

  get "/pingdom_webhook/:service_id" do
    if params.has_key?("message")
      web_hook_processor = PingdomWebhook.new(params[:service_id])
      web_hook_processor.process(params["message"]) ? 200 : 422
    else
      400
    end
  end

  get "/" do
    @alerts = Alert.fetch_all
    erb :index
  end
end
