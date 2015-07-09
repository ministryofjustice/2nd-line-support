require 'json'
require_relative '../models/duty_roster.rb'
require_relative '../lib/presenters/dashboard'
require_relative '../services/pagerduty_alerts'
require_relative '../lib/presenters/v2_dashboard_presenter'

class SupportApp < Sinatra::Application
  get '/' do
    with_updated_data do
      @data = Presenters::Dashboard.default(@duty_roster)
      erb :index
    end
  end

  get '/admin' do
    protected!

    with_updated_data do
      @data = Presenters::Dashboard.admin(@duty_roster)
      erb :admin
    end
  end

  get '/v2-admin.json' do
    content_type :json
    V2DashboardPresenter.new.to_json
  end


  get '/v2-external.json' do
    content_type :json
    V2DashboardPresenter.new.external.to_json
  end


  get '/refresh-duty-roster' do
    protected!

    DutyRoster.default.refresh!
    redirect '/admin'
  end

  private

  def with_updated_data
    @duty_roster = DutyRoster.default
    @duty_roster.update

    PagerDutyAlerts.new.check_alerts

    yield
  end

end