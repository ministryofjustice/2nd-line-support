require 'daemons'
require_relative 'app.rb'
require_relative 'services/event_collector.rb'

Daemons.run_proc('event_collector') do
  loop do
    EventCollector.new.run
    sleep(SupportApp.event_collector_refresh_time_in_seconds)
  end
end
