require 'spec_helper'
require 'services/whos_on_duty'
require 'shared_examples_of_stubbed_api_requests'

describe WhosOnDuty do
  include_examples "stubbed api requests"

  describe '#list' do
    subject { WhosOnDuty.list }

    context 'successful response' do
      before { Timecop.freeze(Time.local(2015, 9, 2)) }
      after  { Timecop.return }

      it 'exposes the primary webops' do
        expect(subject).to include({ rule: 'primary-webop', name: 'Benedetto Lo Giudice' })
        expect(subject).to include({ rule: 'webop', name: 'Lukasz Raczylo' })
      end

      it 'exposes the devs' do
        expect(subject).to include({ rule: 'primary-dev', name: 'Todd Tyree' })
        expect(subject).to include({ rule: 'dev', name: 'Edward Andress' })
      end

      it 'exposes the duty manager' do
        expect(subject).to include(
          {:name=>"Stuart Munro",
           :rule=>"duty_manager",
           :has_phone=>false,
           :contact_methods=>
           [{:type=>"phone", :address=>"(00) 44 12 3456 7891", :label=>"Work Phone"}]}
        )
      end
    end

    context 'empty values response' do
      before do
        allow_any_instance_of(WhosOnDuty).to receive(:fetch_managers).and_return([])
        Timecop.freeze(Time.local(2017, 1, 1))
      end

      after { Timecop.return }

      it 'returns an empty array' do
        expect(Date.today.to_s).to eq('2017-01-01')
        expect(subject).to eql([])
      end
    end

    context 'empty response' do
      before { Timecop.freeze(Time.local(2017, 1, 1)) }
      after  { Timecop.return }

      it 'returns only the manager from pager duty ' do
        expect(subject).to eql([
          {:name=>"Stuart Munro",
           :rule=>"duty_manager",
           :has_phone=>false,
           :contact_methods=>
           [{:type=>"phone", :address=>"(00) 44 12 3456 7891", :label=>"Work Phone"}]}
        ])
      end
    end
  end
end
