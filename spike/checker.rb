require 'pp'
require File.expand_path(File.dirname(__FILE__) + '/../models/pingdom_api.rb')



puts PingdomApi.new.appsdown