require 'spec_helper'

describe RedisClient do

  let(:redis_client)        { RedisClient.instance }

  before(:each) do
    redis_client.flushdb
  end

  context 'Singleton' do
    it 'should always return the same instance' do
      redis_client2 = RedisClient.instance
      expect(redis_client2.object_id).to eq redis_client.object_id
    end
  end

  context 'Hash' do
    it 'should always store and retrieve hashes, stringifying symbol keys or values as required' do
      h = { 'key_1' => 'Data 1', symbol_key: :symbol_value }
      redis_client.set('my_hash', h)
      retrieved_hash = redis_client.get('my_hash')
      expect(retrieved_hash).to eq( { 'key_1' => 'Data 1', 'symbol_key' => 'symbol_value' } )
    end
  end


  context 'Fixnum' do
    it 'should store and retrieve integers' do
      redis_client.set('my_fixnum', 42)
      retrieved_value = redis_client.get('my_fixnum')
      expect(retrieved_value).to eq 42
      expect(retrieved_value).to be_instance_of(Fixnum)
    end
  end

  context 'String' do
    it 'should store and retrieve simple strings' do
      redis_client.set('my_string', 'This is a simple string')
      expect(redis_client.get('my_string')).to eq 'This is a simple string'
    end
  end

  context 'nil' do
    it 'should store and retrieve nils' do
      redis_client.set('my_nil', nil)
      expect(redis_client.get('my_nil')).to be_nil
    end
  end


  context 'non_existent key' do
    it 'should return an empty string' do
      expect(redis_client.get("XXXXXX")).to eq ""
    end
  end


  context '.count_keys' do
    it 'should return the number of keys matching the mask' do
      redis_client.set('alert:pagerduty:ABC001', 'Test alert 1')
      redis_client.set('alert:pagerduty:XYZ003', 'Test alert 1')
      redis_client.set('ooh:members', [ 'member 1', 'member 2'])
      redis_client.set('alert:pagerduty:7883066', 'Test alert 1')

      expect(redis_client.count_keys('alert:pagerduty:*')).to eq 3
      expect(redis_client.count_keys('duty_roster:v2irm')).to eq 0
    end
  end
end