require_relative '../app'
require_relative 'support/helpers'

ENV['RACK_ENV'] = 'test'
require 'rack/test'
require 'webmock/rspec'

ENV['REDISCLOUD_URL'] ||= 'redis://localhost/1'

RSpec.configure do |config|
  config.before(:each) do
    # The Redis wrapper should probably be abstracted, but at the moment it uses the Alert model
    Alert.destroy_all('*')
  end

  config.include Rack::Test::Methods

  config.include Helpers
end