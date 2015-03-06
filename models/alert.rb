require 'redis'
class Alert < Struct.new(:key, :value)

  def self.fetch_all
    redis.keys("*").collect { |key| new(key,redis.get(key)) }
  end

  def self.fetch(key)
    new(key, redis.get(key))
  end

  def self.create(key, data)
    redis.set(key, encode_payload(data))
  end

  def self.destroy(key)
    redis.del(key)
  end

  def self.destroy_all(keys)
    keys = redis.keys(keys)
    redis.del(keys) unless keys.empty?
  end

  def value_hash
    JSON.parse(value)
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
end
