class SupportApp < Sinatra::Application
  configure :test do
    set :duty_roster_google_doc_key, 'testing_key'
    set :duty_roster_google_doc_gid, 'testing_gid'

    set :pager_duty_subdomain,        'moj'
    set :pager_duty_token,            'testing_token'
    set :pager_duty_services,         'service1,service2'
    set :pager_duty_refresh_interval, 1
    set :pager_duty_schedule_ids,     'testing_id,testing_id2'

    set :zendesk_url,                 'https://ministryofjustice.zendesk.com/api/v2'
    set :zendesk_username,            'test-user@digital.justice.gov.uk'
    set :zendesk_token,               'DUMMY-TOKEN'

    set :heroku_name,                 'second-level-support'
    set :heroku_user,                 'moj@heroku.com'
    set :heroku_pass,                 'dummy-heroku-pass'
  end
end