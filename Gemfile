source 'https://rubygems.org'

ruby '2.2.0'

gem 'google-api-client'
gem 'haml'
gem 'sinatra', require: 'sinatra/base'
gem 'redis'
gem 'unicorn'

group :development do
  gem 'foreman'
  gem 'shotgun'
end

group :test, :development do
  gem 'rspec'
  gem 'simplecov', :require => false
	gem 'timecop'
end