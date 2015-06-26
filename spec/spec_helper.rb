ENV['RACK_ENV'] = 'test'

require_relative '../app'
require_relative 'support/helpers'

require 'rack/test'
require 'webmock/rspec'
require 'capybara/rspec'
require 'simplecov'

SimpleCov.start

ENV['REDISCLOUD_URL'] ||= 'redis://localhost/1'
Capybara.app = SupportApp
RSpec.configure do |config|
  config.before(:each) do
    # The Redis wrapper should probably be abstracted, but at the moment it uses the Alert model
    Alert.destroy_all('*')
  end

  config.include Rack::Test::Methods

  config.include Helpers
end

def moj_pagerduty_schedule_regex
	#
	# regex for pagerduty scheduled users API to match this pattern
	# i.e. https://<subdomain>.pagerduty.com/api/v1/schedules/<scheduleId>/users/since=<timestamp>&until=<timestamp>
	#     (minus the timestamp params)
	#
	/#{SupportApp.pager_duty_subdomain}.pagerduty.com\/api\/v1\/schedules\/\w+\/users/
end

def basic_auth
  page.driver.header('Authorization', 'Basic '+ Base64.encode64('test pass:X')) 
end
