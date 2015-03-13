require_relative 'models/alert.rb'
require_relative 'models/traffic_spike.rb'
require_relative 'lib/real_time_analytics.rb'

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