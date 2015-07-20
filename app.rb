$: << File.expand_path('..', __FILE__)

require 'rubygems'
require 'sinatra'
require 'sinatra/partial'
require 'sinatra/json'
require 'excon'
require 'rack'
require 'rack/contrib'
require 'httparty'
require 'slim'

require_relative 'lib/auth'

use Rack::PostBodyContentTypeParser

Excon.defaults[:middlewares] << Excon::Middleware::RedirectFollower

class SupportApp < Sinatra::Application
  register Sinatra::Partial

  helpers do
    def protected!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && Auth.valid_credentials?(*@auth.credentials)
    end
  end
end

# Configuration
require_relative 'config/environments/production'
require_relative 'config/environments/test'

# Controllers
require_relative 'controllers/dashboard_controller'
require_relative 'controllers/monitoring_controller'
require_relative 'controllers/dummy_controller'
# require_relative 'controllers/webhooks_controller'
