require 'spec_helper'

describe "populating the roster", :type => :feature do

  let(:csv_body)    { File.read(File.dirname(__FILE__)  + '/../fixtures/googledocs_schedule_body.csv') }
  let(:csv_new_body){ File.read(File.dirname(__FILE__)  + '/../fixtures/googledocs_schedule_new_body.csv') }

  let(:stub_googledocs_schedule_request_returns_data) do
    stub_request(:get,
                "https://docs.google.com/spreadsheet/pub?gid=testing_gid&key=testing_key&output=csv&single=true"
                ).with(headers: {'Accept'=>'text/csv', 'Host'=>'docs.google.com:443'}
                ).to_return(status: 200, body: csv_body)
  end

  let(:stub_pagerduty_incidents_api_call_returns_data) do
   stub_request(:get,
                "https://moj.pagerduty.com/api/v1/incidents?service=service1,service2&status=triggered,acknowledged"
                ).to_return(:status => 200, :body => {"incidents":[]}.to_json)
  end

  let(:stub_pagerduty_schedule_api_call_returns_data) do
    stub_request(:get,
                 moj_pagerduty_schedule_regex
                ).to_return(:status => 200, :body => { "users": [{ "name": "Stuart Munro" }] }.to_json)
  end

  #
  # need to stub here to prevent netconnect failures during test run
  #
  before do
    stub_googledocs_schedule_request_returns_data
    stub_pagerduty_incidents_api_call_returns_data
    stub_pagerduty_schedule_api_call_returns_data
  end

  # GoogleDocs Rota tests
  # --------------------------------------
  context "when Google docs returns data" do

    let(:stub_googledocs_schedule_request_returns_updated_data) do
     stub_request(:get,
                  "https://docs.google.com/spreadsheet/pub?gid=testing_gid&key=testing_key&output=csv&single=true"
                  ).with(headers: {'Accept'=>'text/csv', 'Host'=>'docs.google.com:443'}
                  ).to_return(status: 200, body: csv_new_body)
    end

    before { visit '/' }

    it "displays in hours support members" do
      expect(page).to have_selector("li", text: "Joel Sugarman")
    end

    it "displays changes to in hours support members" do
      stub_googledocs_schedule_request_returns_updated_data
      visit '/refresh-duty-roster'
      expect(page).to have_selector("li", text: "New Junior Dev")
    end

  end

  context "when Google docs returns NO data" do

    let(:prepopulate_members) { visit '/' }

    let(:stub_googledocs_schedule_returns_no_data) do
      stub_request(:get,
        "https://docs.google.com/spreadsheet/pub?gid=testing_gid&key=testing_key&output=csv&single=true"
        ).with(headers: {'Accept'=>'text/csv', 'Host'=>'docs.google.com:443'}
        ).to_return(status: 200, body: nil)
    end

    it "previously retrieved data is used" do
      prepopulate_members
      stub_googledocs_schedule_returns_no_data
      visit '/refresh-duty-roster'
      expect(page).to have_selector(".dev.phone", text: "Himal Mandalia")
    end

  end

  # PagerDuty Rota tests
  # --------------------------------------
  context "when pagerduty API returns data" do

    before { visit '/' }

    it "displays primary out of hours support member with filled phone icon" do
      expect(page).to have_selector(".webop.phone", text: "Stuart Munro")
    end

    it "displays secondary out of hours support member with unfilled phone icon" do
      expect(page).to have_selector(".dev.phone", text: "Stuart Munro")
    end

  end

  context "when pagerduty API returns NO data" do

    let(:stub_pagerduty_schedule_api_call_returns_no_data) do
      stub_request(:get,
                   moj_pagerduty_schedule_regex
                  ).to_return(:status => 200, :body => nil )
    end

    before do
      stub_pagerduty_schedule_api_call_returns_no_data
      visit '/'
    end

    it "no support members displayed" do
      expect(page).to_not have_content "Stuart Munro"
    end

    it "displays a highlighted warning" do
      expect(page).to have_selector(".bad", text: "not available")
    end
  end

end
