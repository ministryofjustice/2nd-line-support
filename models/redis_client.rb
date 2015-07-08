require 'redis'
require 'singleton'


class RedisClient
  include Singleton

  def initialize
    @redis = Redis.new(:url => ENV["REDISCLOUD_URL"])
  end

  def get(key)
    JSON.parse(@redis.get(key), :quirks_mode => true)
  end

  def set(key, value)
    @redis.set(key, value.to_json)
  end

  def keys(mask)
    @redis.keys(mask)
  end

  def count_keys(mask)
    keys(mask).size
  end


  def flushdb
    @redis.flushdb
  end


end
