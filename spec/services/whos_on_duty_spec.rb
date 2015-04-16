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

    context 'successful response' do
      before do
        stub_request(:get, "https://docs.google.com/spreadsheet/pub?gid=testing_gid&key=testing_key&output=csv&single=true").
          with(headers: {'Accept'=>'text/csv', 'Host'=>'docs.google.com:443'}).
          to_return(status: 200, body: success_body, headers: {})
      end

      it 'returns hash of names' do
        expect(WhosOnDuty.list).to eql({
          'webop': 'webop1',
          'dev1': 'dev2',
          'other_devs': ['dev1'],
          'duty_manager': 'duty_man1'
        })
      end
    end

    context 'empty values response' do
      before do
        stub_request(:get, "https://docs.google.com/spreadsheet/pub?gid=testing_gid&key=testing_key&output=csv&single=true").
          with(headers: {'Accept'=>'text/csv', 'Host'=>'docs.google.com:443'}).
          to_return(status: 200, body: empty_values_body, headers: {})
      end

      it 'returns hash with nil values' do
        expect(WhosOnDuty.list).to eql({
          'webop': nil,
          'dev1': nil,
          'other_devs': [],
          'duty_manager': nil
        })
      end
    end

    context 'empty response' do
      before do
        stub_request(:get, "https://docs.google.com/spreadsheet/pub?gid=testing_gid&key=testing_key&output=csv&single=true").
          with(headers: {'Accept'=>'text/csv', 'Host'=>'docs.google.com:443'}).
          to_return(status: 200, body: empty_body, headers: {})
      end

      it 'returns empty hash' do
        expect(WhosOnDuty.list).to eql({})
      end
    end
  end
end
