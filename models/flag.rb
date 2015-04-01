require 'redis'
class Flag < Struct.new(:key, :value)

  def self.fetch_all
    keys = redis.keys("flag:*")
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

  def self.create(key)
    cache_key = cache_key(key)
    redis.set(cache_key, true)
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

  private

  def self.redis
    @redis ||= Redis.new(:url => ENV["REDISCLOUD_URL"])
  end

  def self.cache_key key
    key[/^flag:/] ? key : "flag:#{key}"
  end
end
