require 'spec_helper'

require 'services/whos_on_duty'

describe WhosOnDuty do

  describe 'list' do
    context 'successful response' do
      before do
        stub_request(:get, "https://docs.google.com/spreadsheet/pub?gid=0&key=1HOQMB1zyTaWzbHOS54NzqWUcT3umxAUwwzQAQlDy3a0&output=csv&single=true").
          with(:headers => {'Accept'=>'text/csv', 'Host'=>'docs.google.com:443'}).
          to_return(:status => 200, :body =>  "Alice,Bob ,Carl", :headers => {})
      end

      it 'returns array of names' do
        expect(WhosOnDuty.list).to eql(['Alice', 'Bob', 'Carl'])
      end
    end
  end
end