require 'spec_helper'

describe 'Flag' do
  let(:redis_double)   { double Redis }

  before(:each) do
    expect(Flag).to receive(:redis).and_return(redis_double)
  end

  describe 'create' do
    it 'should set a key in redis' do
      expect(redis_double).to receive(:set).with('flag:my_key', true)
      Flag.create('my_key')
    end
  end
end
