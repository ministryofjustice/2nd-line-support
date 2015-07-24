require 'spec_helper'

describe Alert do

  # let(:redis_double)   { double Redis }

  # before(:each) do
  #   expect(Alert).to receive(:redis).and_return(redis_double)
  # end
  
  describe 'create' do
    let(:redis_double)   { double Redis }

    before(:each) do
      expect(Alert).to receive(:redis).and_return(redis_double)
    end

    context 'non-hash payload' do
      it 'should set a key with the payload' do
        expect(redis_double).to receive(:set).with('alert:my_key', 'my_data')
        Alert.create('my_key', 'my_data')
      end
    end

    context 'hash payload' do
      it 'should set a key with the payload' do
        my_hash = {'a' => 'A', 'b' => 'B'}
        expect(redis_double).to receive(:set).with('alert:my_key', my_hash.to_json)
        Alert.create('my_key', my_hash)
      end
    end

  end


  describe '#acknowledged?' do
    it 'should not be acknowledged if no acknowledged key in hash' do
      Alert.create('my_alert', {'name' => 'my alert'})
      alert = Alert.fetch('my_alert')
      expect(alert.acknowledged?).to be false
    end
  end


  describe '#message' do
    it 'should return the value of the message key' do
      Alert.create('my_alert', {'name' => 'my alert', 'message' => 'This is my message'})
      alert = Alert.fetch('my_alert')
      expect(alert.message).to eq 'This is my message'
    end
  end

end
