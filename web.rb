require 'rubygems'
require 'sinatra'
require_relative 'models/pingdom_api.rb'


get '/appsdown' do
	puts ">>>>>>>>>>>>>>>> DEBUG message    #{__FILE__}::#{__LINE__} <<<<<<<<<<"
	PingdomApi.new.appsdown
end


