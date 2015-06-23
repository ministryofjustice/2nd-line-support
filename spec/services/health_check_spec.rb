require 'spec_helper'

require_relative '../../services/health_check_service'

describe HealthCheck::Service do
  def stub_component_status(google_up, pagerduty_up, zendesk_up)
    allow_any_instance_of(HealthCheck::GoogleDocs)
      .to receive(:accessible?).and_return(google_up)

    allow_any_instance_of(HealthCheck::PagerdutyApi)
      .to receive(:accessible?).and_return(pagerduty_up)

    allow_any_instance_of(HealthCheck::ZendeskApi)
      .to receive(:accessible?).and_return(zendesk_up)
  end

  it 'should generate a success report if all components accessible' do
    stub_component_status(true, true, true)
    report = subject.report
    
    expect(report.status).to eq '200'
    expect(report.messages).to match /ok/i
  end

  it 'should generate a failure report if a component is not accessible' do
    stub_component_status(true, true, false)
    report = subject.report
    
    expect(report.status).to eq '500'
  end
end