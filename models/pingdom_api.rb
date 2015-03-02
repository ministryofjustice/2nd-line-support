require 'json'

class PingdomApi


	PINGDOM_USER				= "tools@digital.justice.gov.uk"
	PINGDOM_PASSWORD		= "5yEmOel2vILk"
	PINGDOM_API_KEY 		= "bcxbkep4ey7032guahawh4ve0cffq9o1"


	def appsdown
		{
  		"item" => [
		    {
		      "text" => "<font size="18"><ul><li>Civil Claims <font color="red">DOWN</font></li><li>Prison Visit Booking DOWN</li></ul></font>",
		      "type" => 1
		    }
		  ]
		}.to_json
	end




end