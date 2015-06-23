$: << File.expand_path('..', __FILE__)

require 'rubygems'
require 'sinatra'
require 'sinatra/partial'
require 'sinatra/json'
require 'excon'
require 'rack'
require 'rack/contrib'
require 'httparty'

use Rack::PostBodyContentTypeParser

Excon.defaults[:middlewares] << Excon::Middleware::RedirectFollower

class SupportApp < Sinatra::Application
  register Sinatra::Partial
end

# Configuration
require_relative 'config/environments/production'
require_relative 'config/environments/test'

# Controllers
require_relative 'controllers/dashboard_controller'
require_relative 'controllers/monitoring_controller'
require_relative 'controllers/webhooks_controller'
