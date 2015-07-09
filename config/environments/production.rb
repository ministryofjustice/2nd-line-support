class SupportApp < Sinatra::Application
  configure do
    set :partial_template_engine, :erb
    set :sessions, true
    set :session_secret,                                      ENV['SESSION_SECRET'] || SecureRandom.hex(64)
    set :duty_roster_google_doc_key,                          ENV['DUTY_ROSTER_GOOGLE_DOC_KEY']
    set :duty_roster_google_doc_gid,                          ENV['DUTY_ROSTER_GOOGLE_DOC_GID']
    set :duty_roster_google_doc_refresh_interval_in_minutes,  60

    set :pager_duty_subdomain,                                ENV['PAGER_DUTY_SUBDOMAIN']
    set :pager_duty_token,                                    ENV['PAGER_DUTY_TOKEN']
    set :pager_duty_services,                                 [
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
    set :pager_duty_refresh_interval,                         10
    set :pager_duty_schedule_ids,                             "PFX6FHX,PIUMAUI" # for out of hours schedules
    set :pager_duty_irm_schedule_id,                          'PU732K9'
    set :pager_duty_contact_method_types,                     ['phone', 'email']

    set :zendesk_url,                                         ENV['ZENDESK_URL']
    set :zendesk_username,                                    ENV['ZENDESK_USERNAME']
    set :zendesk_token,                                       ENV['ZENDESK_TOKEN']

    set :heroku_name,                                         'second-level-support'
    set :heroku_user,                                         ENV['HEROKU_USER']
    set :heroku_pass,                                         ENV['HEROKU_PASS']

    set :app_user,                                            ENV['APP_USER']
    set :app_pass,                                            ENV['APP_PASS']

    set :event_collector_refresh_time_in_seconds,             30
  end
end