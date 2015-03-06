require 'rubygems'
require 'sinatra'
require_relative 'models/alert.rb'
require_relative 'models/pingdom_api.rb'
require_relative 'models/traffic_spike.rb'
require_relative 'lib/real_time_analytics.rb'


get '/appsdown.json' do
	content_type :json
	PingdomApi.new.appsdown
end

get '/appsdownredis.json' do
	content_type :json
	PingdomApi.new.appsdownredis
end


post '/notify' do
  PingdomApi.new.notify(params[:payload])
end

get '/update_all' do
	TrafficSpike.update
	PingdomApi.new.appsdownredis
	"updated"
end

get '/' do
	@alerts = Alert.fetch_all
	erb :index
end

get	'/traffic_spikes' do
	TrafficSpike.update
	"updated"
end
