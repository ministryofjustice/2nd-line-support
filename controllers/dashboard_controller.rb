require_relative '../models/alert.rb'
require_relative '../models/traffic_spike.rb'
require_relative '../models/flag.rb'
require_relative '../models/duty_roster.rb'

require_relative '../lib/real_time_analytics.rb'

require_relative '../services/whos_on_duty'
require_relative '../services/whos_out_of_hours'
require_relative '../services/pagerduty_alerts'
require_relative '../services/zendesk'

class SupportApp < Sinatra::Application
  ROSTER = DutyRoster.new(settings.duty_roster_google_doc_refresh_interval)

  get '/' do
    with_public_data do
      @whos_on_duty = ROSTER.manager

      erb :index
    end
  end

  get '/admin' do
    protected!

    with_public_data do
      @whos_on_duty           = ROSTER.members
      @whos_out_of_hours      = WhosOutOfHours.list
      @incidents_in_past_week = @zendesk.incidents_for_the_past_week

      erb :admin
    end
  end

  get '/refresh-duty-roster' do
    protected!

    ROSTER.update

    redirect '/admin'
  end

  private 

  def with_public_data
    ROSTER.update if (ROSTER.invalid? || ROSTER.stale?)
      
    PagerDutyAlerts.new.check_alerts

    @alerts           = Alert.fetch_all
    @problem_mode     = Flag.exists?('hipchat:problem_mode')
    @zendesk          = Zendesk.new
    @active_incidents = @zendesk.active_incidents

    yield
  end
end