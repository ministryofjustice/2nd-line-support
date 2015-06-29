require_relative '../models/duty_roster.rb'
require_relative '../lib/presenters/dashboard'
require_relative '../services/pagerduty_alerts'

class SupportApp < Sinatra::Application
  ROSTER = DutyRoster.new(settings.duty_roster_google_doc_refresh_interval)

  get '/' do
    with_updated_data do
      @data = Presenters::Dashboard.default(ROSTER)
      erb :index
    end
  end

  get '/admin' do
    protected!

    with_updated_data do
      @data = Presenters::Dashboard.admin(ROSTER)

      erb :admin
    end
  end

  get '/refresh-duty-roster' do
    protected!

    ROSTER.update
    redirect '/admin'
  end

  private 

  def with_updated_data
    ROSTER.update if (ROSTER.invalid? || ROSTER.stale?)
    PagerDutyAlerts.new.check_alerts

    yield
  end
end