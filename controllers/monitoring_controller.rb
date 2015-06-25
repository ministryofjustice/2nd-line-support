require_relative '../lib/deployment_info'
require_relative '../services/health_check_service'

class SupportApp < Sinatra::Application
  get '/ping.json' do
    data = DeploymentInfo.latest

    json({ status: 200, data: data })  
  end


  get '/healthcheck.json' do
    report = HealthCheck::Service.new.report

    json({ status: report.status, messages: report.messages }) 
  end
end