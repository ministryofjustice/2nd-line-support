require 'spec_helper'

describe 'Doshboard Controller', :type => :feature do

  context 'v2-admin.json' do
    it 'should render the output from the DashboardPresenter' do
      presenter = double V2DashboardPresenter
      expect(V2DashboardPresenter).to receive(:new).and_return(presenter)
      expect(presenter).to receive(:to_json).and_return(expected_v2_json)
      basic_auth
      visit '/v2-admin.json'

      expect(page).to have_content(expected_v2_json)

    end
  end


end


def expected_v2_json
  {
    "status_bar_text" => "3 incidents in the past week",
    "status_bar_status" =>"ok",
    "duty_roster" => {
      "web_ops" => "Peter Idah",
      "dev_1" => "Max Froumentin",
      "dev_2" => "Stephen Richards",
      "ooh_1" => "Steve Marshall",
      "ooh_2" => "Ash Berlin",
      "irm" => "Kamala Hamilton-Brown",
      "irm_telephone" => "7958512425"
    },
    "services" => ["AWS is DOWN"],
    "services_status" => "fail",
    "number_of_alerts" => 0,
    "tools_status" => "warn",
    "tickets"=> []
  }.to_json
end