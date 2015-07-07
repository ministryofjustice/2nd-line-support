require 'spec_helper'

describe RedisClient do

  let(:redis_client)        { RedisClient.instance }

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
end