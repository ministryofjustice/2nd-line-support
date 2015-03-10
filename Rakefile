require_relative "models/alert.rb"
require_relative "models/pingdom_api.rb"
require_relative "models/traffic_spike.rb"
require_relative "lib/real_time_analytics.rb"

task :update_traffic_spikes do
  TrafficSpike.update
end

task :update_pingdom do
  PingdomApi.new.appsdownredis
end

task :update_all do
  Rake::Task["update_traffic_spikes"].invoke
  Rake::Task["update_pingdom"].invoke
end
