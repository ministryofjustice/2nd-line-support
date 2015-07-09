require 'spec_helper'

describe Flag do 

  describe '.create' do

    let(:redis_client)        { RedisClient.instance }

    it 'should set a flag record in the database  to true' do
      Flag.create('mykey')
      expect(redis_client.get('flag:mykey')).to be true

    end
  end

  
end