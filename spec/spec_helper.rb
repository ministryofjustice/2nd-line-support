require 'simplecov'
SimpleCov.start



ENV['RACK_ENV'] = 'test'

require_relative '../app'
require_relative '../models/alert.rb'
require_relative '../models/redis_client'
require_relative 'support/helpers'


require 'rack/test'
require 'webmock/rspec'
require 'capybara/rspec'
require 'pry'
require 'awesome_print'
require 'timecop'


ENV['REDISCLOUD_URL'] ||= 'redis://localhost/1'

Capybara.app = SupportApp

RSpec.configure do |config|
  config.before(:each) do
    #
    # The Redis wrapper should probably be abstracted,
    # but at the moment it uses the Alert model
    #
    Alert.destroy_all('*')
  end

  config.include Rack::Test::Methods
  config.include Helpers
end

