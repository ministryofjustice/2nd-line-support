require 'rubygems'
require 'sinatra'
require_relative 'models/alert.rb'
require_relative 'models/pingdom_api.rb'


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

get '/' do
	@alerts = Alert.fetch_all
	erb :index
end
