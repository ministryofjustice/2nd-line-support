$: << File.expand_path('..', __FILE__)

require 'rubygems'
require 'sinatra'
require 'excon'
require 'sinatra/partial'

Excon.defaults[:middlewares] << Excon::Middleware::RedirectFollower
require_relative 'models/alert.rb'
require_relative 'models/traffic_spike.rb'
require_relative 'lib/real_time_analytics.rb'
require_relative 'services/pingdom_webhook'
require_relative 'services/sensu_webhook'
require_relative 'services/whos_on_duty'

class SupportApp < Sinatra::Application
  register Sinatra::Partial
  DUTY_ROSTER_REFRESH_INTERVAL = JSON.parse(File.read("config/duty_roster_google_doc.json"))["refresh_interval"].to_i || 60
  SESSION_SECRET = ENV['SESSION_SECRET'] || '3eb6db5a9026c547c72708438d496d942e976b252138db7e4e0ee5edd7539457d3ed0fa02ee5e7179420ce5290462018591adaf5f42adcf955db04877827def6'

  set :partial_template_engine, :erb
  set :sessions, true
  set :session_secret, SESSION_SECRET

  get '/pingdom_webhook' do
    if params.has_key?('message')
      webhook_processor = PingdomWebhook.new(params['message'])
      webhook_processor.process ? 200 : 422
    else
      400
    end
  end

  post '/sensu_webhook' do
    if params.has_key?('payload')
      webhook_processor = SensuWebhook.new(params['payload'])
      webhook_processor.process
      200
    else
      400
    end
  end

  before '/' do
    fetch_duty_roster
  end

  get '/' do
    @alerts = Alert.fetch_all
    @whos_on_duty = session[:duty_roster]
    erb :index
  end

  get '/refresh-duty-roster' do
    read_duty_roster_now
    redirect '/'
  end

  private

  def fetch_duty_roster
    read_duty_roster_now if duty_roster_needs_update?
  end

  def duty_roster_needs_update?
    session[:duty_roster].nil? || Time.now > session[:last_duty_roster_fetch] + DUTY_ROSTER_REFRESH_INTERVAL
  end

  def read_duty_roster_now
    session[:duty_roster] = WhosOnDuty.list if WhosOnDuty.list.any? || session[:duty_roster].empty?
    session[:last_duty_roster_fetch] = Time.now
  end
end
