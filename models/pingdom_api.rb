require 'json'

class PingdomApi


	PINGDOM_USER				= "tools@digital.justice.gov.uk"
	PINGDOM_PASSWORD		= "5yEmOel2vILk"
	PINGDOM_API_KEY 		= "bcxbkep4ey7032guahawh4ve0cffq9o1"


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




end