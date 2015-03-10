require "net/http"
require "net/https"
require "json"

class Pinger
  BASE_URL = "https://api.pingdom.com/api/2.0"

  def initialize(action, params = nil)
    @uri  = make_uri(action, params)
    check_envs
  end

  def get
    Net::HTTP.start(@uri.host, @uri.port,
      use_ssl: @uri.scheme == "https",
      verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Get.new @uri.request_uri
      request.add_field("App-Key", ENV["PINGDOM_API_KEY"])
      request.basic_auth ENV["PINGDOM_USERNAME"], ENV["PINGDOM_PASSWORD"]
      response = http.request request # Net::HTTPResponse object
    end
  end

  private

  def check_envs
    %w{ PINGDOM_API_KEY PINGDOM_USERNAME PINGDOM_PASSWORD }.each do |variable|
      if ENV[variable].nil? || ENV[variable] == ""
        raise "Environment Variable #{variable} not set"
      end
    end
  end

  def make_uri(action, params)
    uri_string = "#{BASE_URL}/#{action}"
    uri_string += "?#{params}" unless params.nil?
    URI(uri_string)
  end
end
