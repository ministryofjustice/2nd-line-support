require_relative 'models/alert.rb'

namespace :collector do
  desc 'collect data from Zendesk, PagerDuty and Googledocs and write into REDIS Database'
  task :run_once do
    require_relative 'services/event_collector.rb'
    EventCollector.new.run
  end

  # 'exec' used to run daemon script as daemon needs to start in new ruby interpreter
  namespace :daemon do
    desc 'run as daemon, collecting Zendesk, PagerDuty data periodically and updating REDIS db'
    task :start do
      exec('ruby event_collector_control.rb start')
    end

    desc 'stop daemon'
    task :stop do
      exec('ruby event_collector_control.rb stop')
    end

    desc 'daemon status'
    task :status do
      exec('ruby event_collector_control.rb status')
    end
  end
end

namespace :duty_roster do
  desc 'refresh the REDIS db with latest duty roster details from google doc'
  task :refresh do
    require_relative 'models/duty_roster.rb'
    Excon.defaults[:ssl_verify_peer] = false
    DutyRoster.default.refresh!
  end
end

task :update_traffic_spikes do
  TrafficSpike.update
end

task update_all: :update_traffic_spikes

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  task default: :spec
rescue LoadError
end
