$: << File.expand_path('..', __FILE__)

require 'rubygems'
require 'sinatra'
require 'excon'
require 'sinatra/partial'
require 'rack'
require 'rack/contrib'
require 'httparty'

require_relative 'controllers/dashboard_controller'
require_relative 'controllers/webhooks_controller'

use Rack::PostBodyContentTypeParser

Excon.defaults[:middlewares] << Excon::Middleware::RedirectFollower

class SupportApp < Sinatra::Application
  register Sinatra::Partial

  configure do
    set :partial_template_engine, :erb
    set :sessions, true
    set :session_secret, ENV['SESSION_SECRET'] || '3eb6db5a9026c547c72708438d496d942e976b252138db7e4e0ee5edd7539457d3ed0fa02ee5e7179420ce5290462018591adaf5f42adcf955db04877827def6'

    set :duty_roster_google_doc_key, ENV['DUTY_ROSTER_GOOGLE_DOC_KEY']
    set :duty_roster_google_doc_gid, ENV['DUTY_ROSTER_GOOGLE_DOC_GID']
    set :duty_roster_google_doc_refresh_interval, 60

    set :pager_duty_subdomain, ENV['PAGER_DUTY_SUBDOMAIN']
    set :pager_duty_token, ENV['PAGER_DUTY_TOKEN']
    set :pager_duty_services, [
      #PVB
      "P4WJ9UH", # Pingdom Prod
      "P28KGOJ", # Sensu Prod
      "PA3IQAV", # Pingdom Staging
      "P1R19SP", # Sensu Staging
      
      # PF
      "PRE9BKY", # Pingdom Prod
      "PL1IQHT", # NewRelic Prod
      "PBCJRXW", # Pingdom Staging
      "PG2X10M", # NewRelic Staging
    ].join(",")
    set :pager_duty_refresh_interval, 10
    set :pager_duty_schedule_ids, "PFX6FHX,PIUMAUI" # for out of hours schedules
    set :pager_duty_irm_schedule_id, 'PU732K9'
    set :pager_duty_contact_method_types, ['phone', 'email']

    set :zendesk_url, ENV['ZENDESK_URL']
    set :zendesk_username, ENV['ZENDESK_USERNAME']
    set :zendesk_token, ENV['ZENDESK_TOKEN']

    set :heroku_user, ENV['HEROKU_USER']
    set :heroku_pass, ENV['HEROKU_PASS']
  end

  configure :test do
    set :duty_roster_google_doc_key, 'testing_key'
    set :duty_roster_google_doc_gid, 'testing_gid'

    set :pager_duty_subdomain, 'moj'
    set :pager_duty_token, 'testing_token'
    set :pager_duty_services, "service1,service2"
    set :pager_duty_refresh_interval, 1
    set :pager_duty_schedule_ids, "testing_id,testing_id2"

    set :zendesk_url, 'https://ministryofjustice.zendesk.com/api/v2'
    set :zendesk_username, 'test-user@digital.justice.gov.uk'
    set :zendesk_token, 'DUMMY-TOKEN'

    set :heroku_user, 'moj@heroku.com'
    set :heroku_pass, 'dummy-heroku-pass'
  end
end
