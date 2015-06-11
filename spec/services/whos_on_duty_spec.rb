require 'spec_helper'

require 'services/whos_on_duty'

describe WhosOnDuty do

  describe 'list' do
    let(:success_body) do
      <<-CSV
        ,In Hours Web Ops,In Hours Dev 1,In Hours Dev 2,Junior In Hours Dev,Primary Out of Hours On Call,Secondary Out of Hours On Call
        Currently,webop1,dev1,dev2,,duty_man1,
        Next week,webop2,dev3,dev2,,duty_man2,
        ,,,,,,
        ,,,,,,
        Currently in 1 cell,"webop1
        dev1
        dev2
        ",,,,,
        Next week in 1 cell,"webop2
        dev3
        dev2
        ",,You can use these cells for you team's geckoboard!,They are autopopulated!,,
      CSV
    end

    let(:empty_values_body) do
      <<-CSV
        ,In Hours Web Ops,In Hours Dev 1,In Hours Dev 2,Junior In Hours Dev,Primary Out of Hours On Call,Secondary Out of Hours On Call
        Currently,,,,,,
        Next week,,,,,,
        ,,,,,,
        ,,,,,,
        Currently in 1 cell,"",,,,,
        Next week in 1 cell,"",,You can use these cells for you team's geckoboard!,They are autopopulated!,,
      CSV
    end

    let(:empty_body) do
      <<-CSV
      CSV
    end

    let(:ir_success) do
      {'users'=> [{'name' => 'duty_man1', 'id' => 'XXXXXX'}]}.to_json
    end

    let(:ir_empty) do

    end

    let(:cm_success) do
      {
          'contact_methods' => [
              {
                  'type' => 'phone',
                  'country_code' => '44',
                  'phone_number' => '1234567891',
                  'address' => '1234567891',
                  'label' => 'Work Phone'
              }
          ]
      }.to_json
    end

    let(:stub_pagerduty_schedule_api_requests) do
      stub_request(:get, /.*schedules\/.*\/users.*/).
          to_return(status: 200, body: ir_success, headers: {})
    end

    let(:stub_pagerduty_schedule_empty_api_requests) do
      stub_request(:get, /.*schedules\/.*\/user.s*/).
          to_return(status: 200, body: ir_empty, headers: {})
    end

    let(:stub_pagerduty_contact_methods_api_requests) do
      stub_request(:get, /.*users\/.*\/contact_methods.*/).
          to_return(status: 200, body: cm_success, headers: {})
    end

    context 'successful response' do
      before do
        stub_request(:get, "https://docs.google.com/spreadsheet/pub?gid=testing_gid&key=testing_key&output=csv&single=true").
          with(headers: {'Accept'=>'text/csv', 'Host'=>'docs.google.com:443'}).
          to_return(status: 200, body: success_body, headers: {})
        stub_pagerduty_schedule_api_requests
        stub_pagerduty_contact_methods_api_requests
      end

      it 'returns hash of names' do
        expect(WhosOnDuty.list).to eql([
          {'person': 'webop1', 'rule': 'webop', 'has_phone': true, 'contact_methods': []},
          {'person': 'dev1', 'rule': 'dev', 'has_phone': false, 'contact_methods': []},
          {'person': 'dev2', 'rule': 'dev', 'has_phone': true, 'contact_methods': []},
          {'person': 'duty_man1', 'rule': 'duty_manager', 'has_phone': false, 'contact_methods': [{:type=>"phone", :address=>"(00) 44 12 3456 7891", :label=>"Work Phone"}]},
        ])
      end
    end

    context 'empty values response' do
      before do
        stub_request(:get, "https://docs.google.com/spreadsheet/pub?gid=testing_gid&key=testing_key&output=csv&single=true").
          with(headers: {'Accept'=>'text/csv', 'Host'=>'docs.google.com:443'}).
          to_return(status: 200, body: empty_values_body, headers: {})
        stub_pagerduty_schedule_empty_api_requests
        stub_pagerduty_contact_methods_api_requests
      end

      it 'returns hash with nil values' do
        expect(WhosOnDuty.list).to eql([
          {'person': nil, 'rule': 'webop', 'has_phone': true, 'contact_methods': []},
          {'person': nil, 'rule': 'duty_manager', 'has_phone': false, 'contact_methods': []},
        ])
      end
    end

    context 'empty response' do
      before do
        stub_request(:get, "https://docs.google.com/spreadsheet/pub?gid=testing_gid&key=testing_key&output=csv&single=true").
          with(headers: {'Accept'=>'text/csv', 'Host'=>'docs.google.com:443'}).
          to_return(status: 200, body: empty_body, headers: {})
        stub_pagerduty_schedule_api_requests
        stub_pagerduty_contact_methods_api_requests
      end

      it 'returns empty hash' do
        expect(WhosOnDuty.list).to eql([])
      end
    end
  end
end
