require "json"
require "redis"
require_relative "alert"
require File.expand_path(File.dirname(__FILE__) + "/pinger.rb")

class PingdomApi
  CHECK_TAGS 						= ["level-2-support"]
  PINGDOM_API_TIMEOUT 	= (ENV["PINGDOM_API_TIMEOUT"] || "4").to_i

  def appsdown
    checks = get_checks
    if checks["error"].nil?
      failed_check_ids = []
      checks.each do |check_id, _alert_policy_name|
        failed_check_ids << check_id if perform_pingdom_check(check_id) == false
      end
      if failed_check_ids.empty?
        no_apps_down_response
      else
        apps_down_response(checks, failed_check_ids)
      end
    else
      pingdom_error_response(checks["error"])
    end
  end

  def appsdownredis
    checks = get_checks
    if checks["error"].nil?
      failed_check_ids = []
      checks.each do |check_id, _alert_policy_name|
        failed_check_ids << check_id if perform_pingdom_check(check_id) == false
      end
      record_failed_pingdom_checks_in_redis(checks, failed_check_ids)
    else
      record_pingdom_api_error_in_redis(checks)
    end
  end

  def notify(payload)
    payload = JSON.parse(payload)
    key = "#{payload['client']['name']}/#{payload['check']['name']}"
    record_alert(key, payload)
  end

  private

  def record_alert(key, data)
    Alert.create(key, {"message" => data })
  end

  def remove_alert(key)
    Alert.destroy(key)
  end

  # gets the results from the last check done for this check id and
  # returns true if up, otherwise false
  def perform_pingdom_check(check_id)
    action = "results/#{check_id}"
    params = "limit=1"
    response = Pinger.new(action, params).get
    response_body =  JSON.parse(response.body)
    response_body["results"].first["status"] == "up"
  end

  def record_failed_pingdom_checks_in_redis(checks, failed_check_ids)
    delete_pingdom_records_in_redis
    failed_check_ids.each do |failed_check_id|
      record_pingdom_alert_in_redis(checks, failed_check_id)
    end
  end

  def record_pingdom_api_error_in_redis(checks)
    delete_pingdom_records_in_redis
    key = "pingdom:error"
    Alert.create(key, {message: checks["error"]})
  end

  def record_pingdom_alert_in_redis(checks, failed_check_id)
    key = "pingdom:#{failed_check_id}"
    text = "#{checks[failed_check_id]} DOWN"
    Alert.create(key, {message: text})
  end

  def delete_pingdom_records_in_redis
    Alert.destroy_all("pingdom:*")
  end

  # returns a list of check ids and their alert policy name for
  # each of the alerts tagged with CHECK_TAGS
  def get_checks
    hash = {}
    list = query_pingdom_for_checks
    if list["error"].nil?
      list["checks"].each do |check|
        hash[check["id"]] = check["name"]
      end
      Hash[hash.sort_by { |_k, v| v}]
    else
      list						# return {'error' => 'Pingdom API timeout error'}
    end
  end

  def query_pingdom_for_checks
    params = "tags=#{CHECK_TAGS.join(',')}"
    action = "checks"
    list = nil
    response = nil
    begin
      status = Timeout::timeout(PINGDOM_API_TIMEOUT) {
        response = Pinger.new(action, params).get
      }
    rescue Timeout::Error
      list = {"error" => "Pingdom API timeout (#{PINGDOM_API_TIMEOUT} secs)"}
    else
      list = JSON.parse(response.body)
    end
    list
  end

  def no_apps_down_response
    {
      "item" => [
        {
          "text" => '<font color="green">All apps are GREEN</font>',
          "type" => 0
        }
      ]
    }.to_json
  end

  def pingdom_error_response(message)
    {
      "item" => [
        {
          "text" => %[<font color='red'>#{message}</font>],
          "type" => 0
        }
      ]
    }.to_json
  end

  def apps_down_response(checks, failed_check_ids)
    response = {
      "item" => [
        {
          "text" => nil,
          "type" => 1
        }
      ]
    }
    text = "<ul>"
    failed_check_ids.each do |failed_check_id|
      text += %(<li><font color='red'>#{checks[failed_check_id]} DOWN</li>)
    end
    text += "</ul>"
    response["item"].first["text"] = text
    response.to_json
  end
end
