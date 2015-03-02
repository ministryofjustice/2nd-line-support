require 'json'
require File.expand_path(File.dirname(__FILE__) + '/pinger.rb')

class PingdomApi

	CHECK_TAGS = %W{ civil_claims pvb_live }



	def appsdown
		{
  		"item" => [
		    {
		      "text" => %q{<font size="16"><ul><li>Civil Claims <font color="red">DOWN</font></li><li>Prison Visit Booking <font color="red">DOWN</font></li></ul></font>},
		      "type" => 1
		    }
		  ]
		}.to_json
	end


	def real_appsdown
		checks = get_checks
		failed_checks = []
		checks.each do |check_id, alert_policy_name|
			failed_checks << alert_policy_name if perform_check(check_id) == false
		end
		if failed_checks.empty?
			no_apps_down_response
		else
			apps_down_response(failed_checks)
		end
	end



	private

	def perform_check(check_id)
		true
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


	def apps_down_response(failed_checks)
		response = {
  		"item" => [
		    {
		      "text" => nil,
		      "type" => 1
		    }
		  ]
		}
		error
	end




	# returns a list of check ids and their alert policy name for each of the alerts tagged with CHECK_TAGS
	def get_checks
		params = "tags=#{CHECK_TAGS.join(',')}"
		action = 'checks'
		response = Pinger.new(action, params).get
		list = JSON.parse(response.body)
		hash = {}
		list['checks'].each do | check |
			hash[check['id']] = check['alert_policy_name']
		end
		
	end

end