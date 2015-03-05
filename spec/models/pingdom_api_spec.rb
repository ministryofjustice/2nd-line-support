require 'simplecov'
SimpleCov.start

require 'timecop'
require 'rspec'
require 'pp'
require_relative '../../models/pingdom_api'
require_relative '../fixtures/checks_fixtures'
require 'spec_helper'


describe PingdomApi do

	let(:api)			{ PingdomApi.new }
	let(:redis)		{ Redis.new(:host => ENV['REDIS_HOST'], :port => ENV['REDIS_PORT'].to_i, :db => ENV['REDIS_DB'].to_i) }
	let(:checks)  {
		{ '1224555' => 'Civil Claims',
			'4558778' => 'PVB HTTP',
			'4545451'	=> 'PVB HTTPS'
		}
	}


	before(:each) {
		redis.flushdb
		%w{ pingdom:1 pingdom:2 other:1 other:2 pingdom:33 }.each do |key|
			redis.set(key, {'key' => key, 'payload' => 'data' }.to_json)
		end
	}

	describe '#appsdown' do
		it 'should call perform_check once for every entry in the abbreviated list of checks' do
			expect(api).to receive(:get_checks).and_return(abbreviated_check_list)
			expect(api).to receive(:perform_check).exactly(5).times
			api.appsdown
		end

		it 'should produce no_apps_down_response if all checks pass' do
			expect(api).to receive(:get_checks).and_return(abbreviated_check_list)
			expect(api).to receive(:perform_check).exactly(5).times.and_return(true, true, true, true, true)
			expect(api).to receive(:no_apps_down_response)
			api.appsdown
		end


		it 'should produce apps_down_response if one checks pass' do
			expect(api).to receive(:get_checks).and_return(abbreviated_check_list)
			expect(api).to receive(:perform_check).exactly(5).times.and_return(true, false, true, true, true)
			expect(api).to receive(:apps_down_response)
			api.appsdown
		end
	end


	describe '#perform_check' do
		it 'should call pinger with appropriate url' do
			pinger = double(Pinger)
			response = double('HTTPResponse')
			expect(response).to receive(:body).and_return(json_check_result)
			expect(Pinger).to receive(:new).with('results/1234', 'limit=1').and_return(pinger)
			expect(pinger).to receive(:get).and_return(response)
			api.send(:perform_check, 1234)
		end
	end


	describe '#query_pingdom_for_checks' do
		it 'should call pinger with the correct url and params' do
			response = double('HttpHeader')
			pinger = double Pinger
			expect(response).to receive(:body).and_return(expected_check_fixtures.to_json)
			expect(Pinger).to receive(:new).with('checks', 'tags=level-2-support').and_return(pinger)
			expect(pinger).to receive(:get).and_return(response)
			api.send(:query_pingdom_for_checks)
		end
	end


	describe '#apps_down_response' do
		it 'should return html for every error in checked_ids' do
			expect(api.send(:apps_down_response, abbreviated_check_list, [1163951, 1459666])).to eq(expected_down_json)
		end
	end

	describe '#appsdownredis' do

		context 'no pingdom failures' do 
			it 'should remove all previous pingdom keys only' do
				expect(api).to receive(:get_checks).and_return(checks)
				expect(api).to receive(:perform_check).exactly(3).times.and_return( true, true, true )
				
				api.appsdown
				expect(redis.keys('pingdom:*')).to be_empty
				expect(redis.keys('*').sort).to eq( [ 'other:1', 'other:2' ])
			end
		end

		context 'pingdom failures' do
			it 'should replace existing pingdom records in redis with new ones' do
				expect(redis.keys('*').sort).to eq( ['other:1', 'other:2', 'pingdom:1', 'pingdom:2', 'pingdom:33'] )
				expect(api).to receive(:get_checks).and_return(checks)
				expect(api).to receive(:perform_check).exactly(3).times.and_return( false, false, true )
				
				api.appsdown
				expect(redis.keys('*').sort).to eq( [ 'other:1', 'other:2', 'pingdom:1224555', 'pingdom:4558778' ])
			end
		end
	end


	describe '#record_alert and get_alert' do
		it 'should write the appropriate record in the database' do
			hash = {'key' => 'data', 'key2' => 'data2'}
			api.record_alert('mykey', hash)
			expect( api.get_alert('mykey')).to eq( {'key' => 'mykey', 'payload' => hash} )
		end
	end

	describe 'get_all_alerts' do
		it 'should return an array of all alerts' do
			hash = {'key' => 'data', 'key2' => 'data2'}
			api.record_alert('mykey', hash)
			alerts = api.get_all_alerts
			expect(alerts).to eq(expected_results_from_all_alerts)
		end
	end


	describe '#notify' do
		it 'should store a sensu notification and be able to reconstruct it from the db' do
			payload = sensu_data.to_json
			api.notify(payload)
			key = "host01/frontend_http_check"
			data = api.get_alert(key)
			expect(data['payload']).to eq(sensu_data)
		end
	end
	
end


def sensu_data
	{
		"client" => {
			"name" => "host01",
   		"address" => "10.2.1.11",
   		"subscriptions" => ["all", "frontend", "proxy"],
   		"timestamp" => 1326390159
   	},
 		"check" => {
 			"name"=>"frontend_http_check",
   		"issued" => 1326390169,
   		"output" => "HTTP CRITICAL: HTTP/1.1 503 Service Temporarily Unavailable",
			"status" => 2,
			"command" => "check_http -I 127.0.0.1 -u http://web.example.com/healthcheck.html -R 'pageok'",
			"subscribers" =>["frontend"],
			"interval" => 60,
			"handler" => "campfire",
			"history" => ["0", "2"],
			"flapping" => false
		},
 		"occurrences" => 1,
 		"action" => "create"
 	}

end


def expected_results_from_all_alerts
	[
	 	{	"key"=>"pingdom:2", "payload"=>"data"}, 
	 	{ "key"=>"other:2", "payload"=>"data"}, 
	 	{ "key"=>"pingdom:1", "payload"=>"data"}, 
	 	{ "key"=>"mykey", "payload"=>{"key"=>"data", "key2"=>"data2"}}, 
	 	{ "key"=>"other:1", "payload"=>"data"}, 
	 	{ "key"=>"pingdom:33", "payload"=>"data"}
	]
end