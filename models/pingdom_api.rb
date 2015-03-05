

require 'pp'


require 'json'
require 'redis'
require File.expand_path(File.dirname(__FILE__) + '/pinger.rb')

class PingdomApi

	CHECK_TAGS = [ 'level-2-support' ]

	def initialize
		@redis = Redis.new(:host => ENV['REDIS_HOST'], :port => ENV['REDIS_PORT'].to_i, :db => ENV['REDIS_DB'].to_i)
	end


	def appsdown
		checks = get_checks
		failed_check_ids = []
		checks.each do |check_id, alert_policy_name|
			failed_check_ids << check_id if perform_check(check_id) == false
		end
		failed_check_ids.empty? ? no_apps_down_response : apps_down_response(checks, failed_check_ids)
	end


	def appsdownredis
		checks = get_checks
		failed_check_ids = []
		checks.each do |check_id, alert_policy_name|
			failed_check_ids << check_id if perform_check(check_id) == false
		end
		record_failed_checks_in_redis(checks, failed_check_ids)
	end


	def notify(payload)
		payload = JSON.parse(payload)
		key = "#{payload['client']['name']}/#{payload['check']['name']}"
		record_alert(key, payload)
	end


	def record_alert(key, data)
		@redis.set(key, encode_payload(key, data))
	end


	def remove_alert(key)
		redis = @redis.del(key)
	end


	def get_alert(key)
		JSON.parse(@redis.get(key))
	end


	def get_all_alerts
		redis = @redis
		keys = redis.keys("*")
		array_of_json_results = redis.mget(keys)
		array_of_json_results.map{ |x| JSON.parse(x) }
	end



	private


	def encode_payload(key, data)
		{'key' => key, 'payload' => data }.to_json
	end

	# gets the results from the last check done for this check id and returns true if up, otherwise false
	def perform_check(check_id)
		action = "results/#{check_id}"
		params = 'limit=1'
		response = Pinger.new(action, params).get
		response_body =  JSON.parse(response.body)
		response_body['results'].first['status'] == 'up'
	end


	def record_failed_checks_in_redis(checks, failed_check_ids)
		delete_pingdom_records_in_redis
		failed_check_ids.each do |failed_check_id|
			record_pingdom_alert_in_redis(checks, failed_check_id)
		end
	end


	def record_pingdom_alert_in_redis(checks, failed_check_id)
		key = "pingdom:#{failed_check_id}"
		text = "#{checks[failed_check_id]} DOWN}"
		@redis.set(key, text)
	end

	def delete_pingdom_records_in_redis
		keys = @redis.keys("pingdom:*")
		@redis.del(keys)
	end




	# returns a list of check ids and their alert policy name for each of the alerts tagged with CHECK_TAGS
	def get_checks
		hash = {}
		list = query_pingdom_for_checks
		list['checks'].each do | check |
			hash[check['id']] = check['name']
		end
		Hash[hash.sort_by{ |k,v| v}]
	end

	def query_pingdom_for_checks
		params = "tags=#{CHECK_TAGS.join(',')}"
		action = 'checks'
		response = Pinger.new(action, params).get
		list = JSON.parse(response.body)
	end





end