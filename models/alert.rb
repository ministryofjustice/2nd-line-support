require 'redis'
class Alert < Struct.new(:key, :value)

  def self.fetch_all
    keys = redis.keys("*")
    keys.collect { |key| new(key,redis.get(key)) }
  end

  def self.fetch(key)
    cache_key = cache_key(key)
    new(cache_key, redis.get(cache_key))
  end

  def self.exists?(key)
    cache_key = cache_key(key)
    redis.exists(cache_key)
  end

  def self.create(key, data)
    cache_key = cache_key(key)
    redis.set(cache_key, encode_payload(data))
  end

  def self.destroy(key)
    cache_key = cache_key(key)
    redis.del(cache_key)
  end

  def self.destroy_all(key_pattern)
    cache_key = cache_key(key_pattern)
    keys = redis.keys(cache_key)
    redis.del(keys) unless keys.empty?
  end

  def value_hash
    JSON.parse(value)
  end

  def message
    value_hash['message']
  end

  private

  def self.encode_payload(data)
    if data.is_a?(Hash)
      data.to_json
    else
      data
    end
  end

  def self.redis
    @redis ||= Redis.new(:url => ENV["REDISCLOUD_URL"])
  end

  def self.cache_key key
    key[/^alert:/] ? key : "alert:#{key}"
  end
end
