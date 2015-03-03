require 'simplecov'
SimpleCov.start

require 'rspec'
require 'pp'
require_relative '../../models/pingdom_api'
require_relative '../fixtures/checks_fixtures'


describe PingdomApi do

	let(:api)			{ PingdomApi.new }

	describe '#check_list' do
		it 'should produce an abbreviated list of checks from the pingdom response' do 
			expect(api).to receive(:query_pingdom_for_checks).and_return(expected_check_fixtures)
			expect(api.send(:get_checks)).to eq(abbreviated_check_list)
		end
	end

	describe '#appsdown' do
		it 'should call perform_check once for every entry in the abbreviated list of checks' do
			expect(api).to receive(:get_checks).and_return(abbreviated_check_list)
			expect(api).to receive(:perform_check).exactly(5).times
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

	
end