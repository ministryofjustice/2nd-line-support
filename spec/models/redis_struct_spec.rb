require 'spec_helper'

describe RedisStruct do

  let(:redis)          { double Redis }


  describe '.fetch_all' do
    it 'should return an array of results for every key in the db' do
      allow(RedisStruct).to receive(:redis).and_return(redis)
      expect(redis).to receive(:keys).with(':*').and_return( [ 'abc', 'def' ] )
      expect(redis).to receive(:get).with('abc').and_return('ABC')
      expect(redis).to receive(:get).with('def').and_return('DEF')
      expect(RedisStruct.fetch_all).to eq( [ RedisStruct.new('abc', 'ABC'), RedisStruct.new('def', 'DEF') ] )
    end
  end

end