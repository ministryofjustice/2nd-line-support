require 'json'
require File.expand_path(File.dirname(__FILE__) + '/pinger.rb')

class PingdomApi

	CHECK_TAGS = [ 'level-2-support' ]

	def appsdown
		checks = get_checks
		failed_check_ids = []
		checks.each do |check_id, alert_policy_name|
			failed_check_ids << check_id if perform_check(check_id) == false
		end
		failed_check_ids.empty? ? no_apps_down_response : apps_down_response(checks, failed_check_ids)
	end



	private

	# gets the results from the last check done for this check id and returns true if up, otherwise false
	def perform_check(check_id)
		action = "results/#{check_id}"
		params = 'limit=1'
		response = Pinger.new(action, params).get
		response_body =  JSON.parse(response.body)
		response_body['results'].first['status'] == 'up'
	end




	def no_apps_down_response
		{
  		"item" => [
		    {
		      "text" => %q{<font size="16" color="greeen">All apps are GREEN</font>},
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
			text += %q(<li><font size="16" color="red">#{checks['failed_check_id']} DOWN</li>)
		end
		text += "</ul>"
		response['item'].first['text'] = text
		response.to_json
	end




	# returns a list of check ids and their alert policy name for each of the alerts tagged with CHECK_TAGS
	def get_checks
		params = "tags=#{CHECK_TAGS.join(',')}"
		action = 'checks'
		response = Pinger.new(action, params).get
		list = JSON.parse(response.body)
		hash = {}
		list['checks'].each do | check |
			hash[check['id']] = check['name']
		end
		Hash[hash.sort_by{ |k,v| v}]
	end

end