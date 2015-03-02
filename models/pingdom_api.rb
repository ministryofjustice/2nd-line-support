require 'json'

class PingdomApi


	PINGDOM_USER				= "tools@digital.justice.gov.uk"
	PINGDOM_PASSWORD		= "5yEmOel2vILk"
	PINGDOM_API_KEY 		= "bcxbkep4ey7032guahawh4ve0cffq9o1"


	def appsdown
		puts ">>>>>>>>>>>>>>>> DEBUG message    #{__FILE__}::#{__LINE__} <<<<<<<<<<"
		{
  		"item" => [
		    {
		      "text" => "Unfortunately, as you probably already know, people",
		      "type" => 0
		    },
		    {
		      "text" => "As you might know, I am a full time Internet",
		      "type" => 1
		    }
		  ]
		}.to_json
	end




end