require 'spec_helper'

require 'services/whos_on_duty'

describe WhosOnDuty do

  describe 'list' do
    let(:body) do
      <<-CSV
        ,In Hours Web Ops,In Hours Dev 1,In Hours Dev 2,Junior In Hours Dev,Primary Out of Hours On Call,Secondary Out of Hours On Call
        Currently,Kyriakos Oikonomakos,Himal Mandalia ,Rob Mckinnon,,,
        Next week,Lucasz Raczylo,Himal Mandalia ,Ravi,,,
        ,,,,,,
        ,,,,,,
        Currently in 1 cell,"Kyriakos Oikonomakos
        Himal Mandalia
        Rob Mckinnon
        ",,,,,
        Next week in 1 cell,"Lucasz Raczylo
        Himal Mandalia
        Ravi
        ",,You can use these cells for you team's geckoboard!,They are autopopulated!,,
      CSV
    end

    context 'successful response' do
      before do
        stub_request(:get, "https://docs.google.com/spreadsheet/pub?gid=testing_gid&key=testing_key&output=csv&single=true").
          with(headers: {'Accept'=>'text/csv', 'Host'=>'docs.google.com:443'}).
          to_return(status: 200, body: body, headers: {})
      end

      it 'returns array of names' do
        expect(WhosOnDuty.list).to eql(['Himal Mandalia', 'Kyriakos Oikonomakos', 'Rob Mckinnon'])
      end
    end
  end
end
