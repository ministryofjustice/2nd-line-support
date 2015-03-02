require 'rubygems'
require 'sinatra'
require_relative 'models/pingdom_api.rb'


get '/appsdown' do
	PingdomApi.new.appsdown
end


