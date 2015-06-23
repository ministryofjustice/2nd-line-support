require_relative '../models/alert.rb'
require_relative '../models/traffic_spike.rb'
require_relative '../models/flag.rb'

require_relative '../lib/real_time_analytics.rb'

require_relative '../services/whos_on_duty'
require_relative '../services/whos_out_of_hours'
require_relative '../services/pagerduty_alerts'
require_relative '../services/zendesk'

class SupportApp < Sinatra::Application
  before '/' do
    check_updates
  end

  get '/' do
    @alerts = Alert.fetch_all
    @problem_mode = Flag.exists?('hipchat:problem_mode')
    @whos_on_duty = session[:duty_roster]
    @whos_out_of_hours = WhosOutOfHours.list
    @zendesk ||= Zendesk.new()
    @incidents_in_past_week = @zendesk.incidents_for_the_past_week
    @active_incidents = @zendesk.active_incidents
    erb :index
  end

  get '/refresh-duty-roster' do
    read_duty_roster_now
    redirect '/'
  end

  private

  def check_updates
    if duty_roster_needs_update?
      read_duty_roster_now
    end
    PagerDutyAlerts.new().check_alerts
  end

  def duty_roster_needs_update?
    session[:duty_roster].nil? || Time.now > session[:last_duty_roster_fetch] + settings.duty_roster_google_doc_refresh_interval || session[:duty_roster].is_a?(Hash)
  end

  def read_duty_roster_now
    members = WhosOnDuty.list
    session[:duty_roster] = members if members.any? || session[:duty_roster].nil?
    session[:last_duty_roster_fetch] = Time.now
  end
end