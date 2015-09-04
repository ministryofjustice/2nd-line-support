require 'spec_helper'
require_relative '../../services/floatschedule_rota'

describe FloatscheduleRota do
  let(:spec_dir)         { File.dirname(__FILE__) }
  let(:example_response) { File.read(spec_dir + '/../fixtures/float_tasks_api_response.json') }

  before { allow(Excon).to receive(:get).and_return(double('response', body: example_response)) }

  describe 'fetchng from the float api' do
    before { described_class.new.fetch_data }

    it 'uses the correct endpoint' do
      expect(Excon).to have_received(:get).with('https://api.floatschedule.com/api/v1/tasks', anything)
    end

    it 'requests json' do
      expect(Excon).to have_received(:get).with(anything, headers: hash_including('Accept' => 'application/json'))
    end

    it 'authenticates using SupportApp.float_api_key' do
      expect(Excon).to have_received(:get).with(anything, headers: hash_including('Authorization' => 'Bearer dummy-float-api-key'))
    end
  end

  describe 'parsing the response' do
    it { expect(JSON).to receive(:load).with(example_response); described_class.new.fetch_data }
  end

  context 'task and time handling' do
    subject { FloatscheduleRota.new }

    before do
      Timecop.freeze(Time.local(2015, 9, 2))
      expect(Excon).to receive(:get).and_return(double('response', body: example_response))
      subject.fetch_data
    end

    after { Timecop.return }

    let(:all_names) do
      ['Joel Sugarman', 'Benedetto Lo Giudice', 'Todd Tyree',
       'Lukasz Raczylo', 'Edward Andress', 'Mel Pierre']
    end
    let(:current_names) { all_names - ['Joel Sugarman'] }

    it 'expose only the array of tasks from the API repsonse' do
      expect(subject.send(:tasks).map{ |t| t['person_name'] }).to match_array(all_names)
    end

    it 'expose only the currently applicable tasks from the API response' do
      expect(subject.send(:current_tasks).map{ |t| t['person_name'] }).to match_array(current_names)
    end

    describe 'tolerates missing entries' do
      before { Timecop.freeze(Time.local(2017, 1, 1)) }
      after  { Timecop.return }

      it 'does not error if there are no entries for the time period' do
        expect{ subject.primary_webop }.to_not raise_error
      end

      it 'returns empty hashes for the convientience methods' do
        [:primary_webop, :secondary_webop, :primary_dev, :secondary_dev].each do |role|
          expect(subject.send(role)).to eq({})
        end
      end
    end

  end

  context 'specific roles' do
    subject { FloatscheduleRota.new }

    before do
      Timecop.freeze(Time.local(2015, 9, 2))
      expect(Excon).to receive(:get).and_return(double('response', body: example_response))
      subject.fetch_data
    end

    after { Timecop.return }

    describe '#primary_webop' do
      it { expect(subject.primary_webop).to eq({ rule: 'primary-webop', name: 'Benedetto Lo Giudice' }) }
    end

    describe '#secondary_webop' do
      it { expect(subject.secondary_webop).to eq({ rule: 'webop', name: 'Lukasz Raczylo' }) }
    end

    describe '#primary_dev' do
      it { expect(subject.primary_dev).to eq({ rule: 'primary-dev', name: 'Todd Tyree' }) }
    end

    describe '#secondary_dev' do
      it { expect(subject.secondary_dev).to eq({ rule: 'dev', name: 'Edward Andress' }) }
    end

  end
end
