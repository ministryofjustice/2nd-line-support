require_relative 'redis_struct'

class Alert < RedisStruct

  def self.key_prefix
    "alert"
  end

  def self.create(key, data)
    cache_key = cache_key(key)
    redis.set(cache_key, encode_payload(data))
  end

  def value_hash
    JSON.parse(value)
  end

  def acknowledged?
    ack_status = value_hash['acknowledged']
    return ack_status=="acknowledged"?true:false
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

end
