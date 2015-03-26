require 'spec_helper'

describe "populating the roster", :type => :feature do

  let(:successful_request_stub) { stub_request(:get, "https://docs.google.com/spreadsheet/pub?gid=1997221201&key=1j28ELnPgKi0fO6io6aQd-ROUlbXBaiEo63ct4WQVtUQ&output=csv&single=true").
      with(headers: {'Accept'=>'text/csv', 'Host'=>'docs.google.com:443'}).
      to_return(status: 200, body: body, headers: {}) }
  let(:failed_request_stub) { stub_request(:get, "https://docs.google.com/spreadsheet/pub?gid=1997221201&key=1j28ELnPgKi0fO6io6aQd-ROUlbXBaiEo63ct4WQVtUQ&output=csv&single=true").
      with(headers: {'Accept'=>'text/csv', 'Host'=>'docs.google.com:443'}).
      to_return(status: 200, body: nil, headers: {}) }
  let(:new_request_stub) { stub_request(:get, "https://docs.google.com/spreadsheet/pub?gid=1997221201&key=1j28ELnPgKi0fO6io6aQd-ROUlbXBaiEo63ct4WQVtUQ&output=csv&single=true").
      with(headers: {'Accept'=>'text/csv', 'Host'=>'docs.google.com:443'}).
      to_return(status: 200, body: new_body, headers: {}) }
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
  let(:new_body) do
        <<-CSV
          ,In Hours Web Ops,In Hours Dev 1,In Hours Dev 2,Junior In Hours Dev,Primary Out of Hours On Call,Secondary Out of Hours On Call
          Currently,Kyriakos Oikonomakos,Evangelos Giataganas ,Rob Mckinnon,,,
          Next week,Lucasz Raczylo,Himal Mandalia ,Ravi,,,
          ,,,,,,
          ,,,,,,
          Currently in 1 cell,"Kyriakos Oikonomakos
          Evangelos Giataganas
          Rob Mckinnon
          ",,,,,
          Next week in 1 cell,"Lucasz Raczylo
          Himal Mandalia
          Ravi
          ",,You can use these cells for you team's geckoboard!,They are autopopulated!,,
        CSV
  end

  before do
    successful_request_stub
    visit '/'
  end

  context "when Google docs successfully returns data" do
    it "is displayed on the dashboard" do
      expect(page).to have_content "Himal Mandalia"
    end
    it "changes to the spreadsheet are reflected on the dashboard" do
      new_request_stub
      visit '/refresh-duty-roster'
      expect(page).to have_content "Evangelos Giataganas"
    end
  end

  context "when Google docs fails to return data" do
    before do
      failed_request_stub
      visit '/refresh-duty-roster'
    end
    it "previously retrieved data is used" do
      expect(page).to have_content "Himal Mandalia"
    end
  end

end