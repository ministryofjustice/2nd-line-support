require_relative '../lib/real_time_analytics.rb'

class TrafficSpike
  def self.update
    Alert.destroy_all("trafficspike:*")
    TrafficSpike.load_from_json.each do |traffic_spike|
      if traffic_spike.unacceptable?
        Alert.create("trafficspike:#{traffic_spike.config["profile_id"]}", {message: traffic_spike.alert})
      end
    end
  end

  def self.load_from_json
    realtime_analytic_limits = JSON.parse(File.read("config/realtime_analytic_limits.json"))["limits"]
    realtime_analytic_limits.collect {|config| TrafficSpike.new(config)}
  end

  def initialize(config)
    @config = config
  end

  attr_reader :config

  def current_users
    RealTimeAnalytics.instance.current_visitor_count(config["profile_id"])
  end

  def unacceptable?
    current_users > config["limit"]
  end

  def alert
    "#{config["name"]} currently has #{current_users} users! (we don't expect more than #{config["limit"]})"
  end
end
