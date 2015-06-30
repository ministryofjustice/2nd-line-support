require 'spec_helper'

describe "populating the roster", :type => :feature do
  let(:csv_dir)       { File.dirname(__FILE__)                                              }
  let(:csv_body)      { File.read(csv_dir + '/../fixtures/googledocs_schedule_body.csv')    }
  let(:csv_new_body)  { File.read(csv_dir + '/../fixtures/googledocs_schedule_new_body.csv')}
  #
  # Prevent netconnect failures during test run
  #
  before do
    googledocs_schedule_request_returns_data(csv_body)
    pagerduty_incidents_api_call_returns_data
    pagerduty_schedule_api_call_returns_data
    pagerduty_schedule_api_requests
    pagerduty_contact_methods_api_requests
    zendesk_api_call
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
    before do
     reset_roster!
     basic_auth
     visit '/admin' 
    end

    it "displays in hours support members" do
      expect(page).to have_selector("li", text: "Joel Sugarman")
    end

    it "displays changes to in hours support members" do
      googledocs_schedule_request_returns_data(csv_new_body)
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

    before(:each) do
      reset_roster!
    end

    it "previously retrieved data is used" do
      prepopulate_members
      googledocs_schedule_request_returns_data(nil)
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
    before do
      reset_roster!
      pagerduty_schedule_api_call_returns_no_data
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
