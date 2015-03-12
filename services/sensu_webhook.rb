class SensuWebhook
  REDIS_KEY_PREFIX = 'sensu'

  def initialize(payload)
    @payload = payload
  end

  def process
    service_id = @payload['key']
    redis_key = "#{REDIS_KEY_PREFIX}/#{service_id}"

    case @payload['event']['action']
      when 'create'
        redis_message = "#{service_id}: #{@payload['event']['check']['output']}"
        Alert.create(redis_key, { message: redis_message } )
      when 'resolve'
        Alert.destroy(redis_key)
    end

    true
  end
end