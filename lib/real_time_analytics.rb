require "google/api_client"
require "singleton"

class RealTimeAnalytics
  include Singleton

  def current_visitor_count(profile_id)
    analytics = client.discovered_api("analytics", "v3")
    visit_count = client.execute(
      api_method: analytics.data.realtime.get,
      parameters: {
        "ids" => "ga:" + profile_id,
        "metrics" => "ga:activeVisitors",
      }
    )
    visit_count.data.rows.first.first.to_i
  end

private

  def service_account_email
    ENV["GOOGLE_SERVICE_ACCOUNT"]
  end

  def key_file
    ENV["GOOGLE_P12"]
  end

  def key
    @key ||= OpenSSL::PKey::RSA.new(key_file, "notasecret")
  end

  def client
    unless @client
      @client = Google::APIClient.new(
        application_name: "[YOUR APPLICATION NAME]",
        application_version: "0.01",
      )
      @client.authorization = Signet::OAuth2::Client.new(
        token_credential_uri: "https://accounts.google.com/o/oauth2/token",
        audience: "https://accounts.google.com/o/oauth2/token",
        scope: "https://www.googleapis.com/auth/analytics.readonly",
        issuer: service_account_email,
        signing_key: key,
      )
      @client.authorization.fetch_access_token!
    end
    @client
  end
end
