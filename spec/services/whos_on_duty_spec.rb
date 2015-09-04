require 'spec_helper'

require 'services/whos_on_duty'
require 'support/request_handlers'

describe WhosOnDuty do
  include RequestHandlers
  
  describe 'list' do
    let(:csv_dir)           { File.dirname(__FILE__)                                       }
    let(:success_body)      { File.read(csv_dir + '/../fixtures/whos_on_duty_success.csv') }
    let(:empty_values_body) { File.read(csv_dir + '/../fixtures/whos_on_duty_empty.csv')   }

    context 'successful response' do
      before do
      after  { Timecop.return }

      it 'exposes the webops' do
        expect(subject).to include({ rule: 'primary-webop', name: 'Benedetto Lo Giudice' })
        expect(subject).to include({ rule: 'webop', name: 'Lukasz Raczylo' })
      end

      it 'exposes the devs' do
        expect(subject).to include({ rule: 'primary-dev', name: 'Todd Tyree' })
        pagerduty_contact_methods_api_returns(cm_success)
      end

      it 'returns hash of names' do
        expect(WhosOnDuty.list).to eql([
          {'name': 'webop1', 'rule': 'webop', 'has_phone': true, 'contact_methods': []},
          {'name': 'dev1', 'rule': 'dev', 'has_phone': false, 'contact_methods': []},
          {'name': 'dev2', 'rule': 'dev', 'has_phone': true, 'contact_methods': []},
          {'name': 'duty_man1', 'rule': 'duty_manager', 'has_phone': false, 'contact_methods': 
            [{:type=>"phone", :address=>"(00) 44 12 3456 7891", :label=>"Work Phone"}]},
        ])
      end
    end

    context 'empty values response' do
      before do
        googledocs_schedule_request_returns(nil)
        pagerduty_schedule_api_returns(nil)
        pagerduty_contact_methods_api_returns(cm_success)
      end

      it 'returns an empty array' do
        expect(WhosOnDuty.list).to eql([])
      end
    end

    context 'empty response' do
      before do
        googledocs_schedule_request_returns(empty_values_body)
        pagerduty_schedule_api_returns(nil)
      end

      it 'returns only the manager from pager duty ' do
        expect(WhosOnDuty.list).to eql([])
      end
    end

    context 'GoogleDoc::ReadAccessError' do
      it 'should return an emtpy array' do
        allow(WhosOnDuty).to receive(:source).and_raise(GoogleDoc::ReadAccessError.new('key', 'gid'))
        expect(WhosOnDuty.list).to eq( [] )
      end
    end
  end
end
