require 'spec_helper'

describe "populating the roster", :type => :feature do
  let(:csv_dir)       { File.dirname(__FILE__)                                              }
  let(:csv_body)      { File.read(csv_dir + '/../fixtures/googledocs_schedule_body.csv')    }
  let(:csv_new_body)  { File.read(csv_dir + '/../fixtures/googledocs_schedule_new_body.csv')}

  let(:stub_googledocs_schedule_request_returns_data) do
    stub_request(
      :get,
      "https://docs.google.com/spreadsheet/pub?gid=testing_gid&key=testing_key&output=csv&single=true"
    ).with(headers: {'Accept'=>'text/csv', 'Host'=>'docs.google.com:443'})
     .to_return(status: 200, body: csv_body)
  end

  let(:stub_pagerduty_incidents_api_call_returns_data) do
    stub_request(
      :get,
      "https://moj.pagerduty.com/api/v1/incidents?service=service1,service2&status=triggered,acknowledged"
    ).to_return(:status => 200, :body => {"incidents":[]}.to_json)
  end

  let(:stub_pagerduty_schedule_api_call_returns_data) do
    stub_request(
      :get,
      moj_pagerduty_schedule_regex
    ).to_return(:status => 200, :body => { "users": [{ "name": "Stuart Munro" }] }.to_json)
  end

  let(:ir_success) do
    { 
      'users' => [
        {
          'name' => 'duty_man1', 
          'id'   => 'XXXXXX'
        }
      ]
    }.to_json
  end

  let(:cm_success) do
    {
      'contact_methods' => [
        {
          'type'         => 'phone',
          'country_code' => '44',
          'phone_number' => '1234567891',
          'address'      => '1234567891',
          'label'        => 'Work Phone'
        }
      ]
    }.to_json
  end

  let(:stub_pagerduty_schedule_api_requests) do
    stub_request(:get, /.*schedules\/.*\/users?since=.*/).
        to_return(status: 200, body: ir_success, headers: {})
  end

  let(:stub_pagerduty_contact_methods_api_requests) do
    stub_request(:get, /.*users\/.*\/contact_methods.*/).
        to_return(status: 200, body: cm_success, headers: {})
  end

  let(:stub_zendesk_api_call) do
    stub_request(
      :get,
      /https:\/\/.*@ministryofjustice\.zendesk\.com\/api\/.*/
    ).to_return(
      :status => 200,
      :headers => {
        "Content-Type": "application/json"
      },
      :body => {
        "results" => [],
        "facets" => nil,
        "next_page" => nil,
        "previous_page" => nil,
        "count" => 0
      }.to_json
    )
  end
  #
  # Prevent netconnect failures during test run
  #
  before do
    stub_googledocs_schedule_request_returns_data
    stub_pagerduty_incidents_api_call_returns_data
    stub_pagerduty_schedule_api_call_returns_data
    stub_pagerduty_schedule_api_requests
    stub_pagerduty_contact_methods_api_requests
    stub_zendesk_api_call
  end

  context 'When no authorisation is provided' do
    it 'should not display the admin page' do
      visit '/admin'

      expect(page.status_code).to eq 401
      expect(page.body).to match /not authorized/i
    end

    it 'should display the public page (index)' do
      visit '/'
      
      expect(page.status_code).to eq 200
      expect(page.body).to match /on duty/i
    end
  end

  context 'When authorisation is provided' do
    it 'should display the admin page' do
      basic_auth
      visit '/admin'

      expect(page.status_code).to eq 200
      expect(page.body).to match /on duty/i
    end
  end

  # GoogleDocs Rota tests
  # --------------------------------------
  context "when Google docs returns data" do
    let(:stub_googledocs_schedule_request_returns_updated_data) do
      stub_request(
        :get,
        "https://docs.google.com/spreadsheet/pub?gid=testing_gid&key=testing_key&output=csv&single=true"
      ).with(headers: {'Accept'=>'text/csv', 'Host'=>'docs.google.com:443'})
       .to_return(status: 200, body: csv_new_body)
    end

    before do
     Capybara.app::ROSTER.clear!
     basic_auth
     visit '/admin' 
    end

    it "displays in hours support members" do
      expect(page).to have_selector("li", text: "Joel Sugarman")
    end

    it "displays changes to in hours support members" do
      stub_googledocs_schedule_request_returns_updated_data
      basic_auth
      visit '/refresh-duty-roster'
      expect(page).to have_selector("li", text: "New Junior Dev")
    end
  end

  context "when Google docs returns NO data" do
    def prepopulate_members
      basic_auth
      visit '/admin'
    end

    let(:stub_googledocs_schedule_returns_no_data) do
      stub_request(:get,
        "https://docs.google.com/spreadsheet/pub?gid=testing_gid&key=testing_key&output=csv&single=true"
        ).with(headers: {'Accept'=>'text/csv', 'Host'=>'docs.google.com:443'}
        ).to_return(status: 404, body: nil)
    end

    before(:each) do
      Capybara.app::ROSTER.clear!
    end

    it "previously retrieved data is used" do
      prepopulate_members
      stub_googledocs_schedule_returns_no_data
      basic_auth
      visit '/refresh-duty-roster'
      expect(page).to have_selector(".dev.phone", text: "Himal Mandalia")
    end
  end

  # PagerDuty Rota tests
  # --------------------------------------
  context "when pagerduty API returns data" do
    before do 
      basic_auth
      visit '/admin' 
    end

    it "displays primary out of hours support member with filled phone icon" do
      expect(page).to have_selector(".webop.phone", text: "Stuart Munro")
    end

    it "displays secondary out of hours support member with unfilled phone icon" do
      expect(page).to have_selector(".dev.phone", text: "Stuart Munro")
    end
  end

  context "when pagerduty API returns NO data" do
    let(:stub_pagerduty_schedule_api_call_returns_no_data) do
      stub_request(
        :get,
        moj_pagerduty_schedule_regex
      ).to_return(:status => 200, :body => nil )
    end

    before do
      Capybara.app::ROSTER.clear!
      stub_pagerduty_schedule_api_call_returns_no_data
      basic_auth
      visit '/admin'
    end

    it "no support members displayed" do
      expect(page).to_not have_content "Stuart Munro"
    end

    it "displays a highlighted warning" do
      expect(page).to have_selector(".bad", text: "not available")
    end
  end
end
