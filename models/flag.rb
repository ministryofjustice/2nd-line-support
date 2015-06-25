require_relative 'redis_struct'

class Flag < RedisStruct
  
  def self.key_prefix
    "flag"
  end
  
  def self.create(key)
    cache_key = cache_key(key)
    redis.set(cache_key, true)
  end
end
