require 'spec_helper'
require 'support/request_handlers'

shared_examples "stubbed api requests" do
  include RequestHandlers

  let(:csv_dir)       { File.dirname(__FILE__)                                            }
  let(:float_json)    { File.read(csv_dir + '/fixtures/float_tasks_api_response.json')    }
  let(:csv_new_body)  { File.read(csv_dir + '/fixtures/googledocs_schedule_new_body.csv') }
  let(:incidents)     { '{"incidents":[]}'                                                }
  let(:users)         { '{"users":[{"name":"Stuart Munro"}]}'                             }
  let(:tickets)       { '{"results":[],"count":0}'                                        }

  before do
    float_tasks_api_request_returns(float_json)
    googledocs_schedule_request_returns(csv_body)
    pagerduty_incidents_api_returns(incidents)
    pagerduty_schedule_api_returns(users)
    pagerduty_contact_methods_api_returns(cm_success)
    zendesk_api_returns(tickets)
  end
end
