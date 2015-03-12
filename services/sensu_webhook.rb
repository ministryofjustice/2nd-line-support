class SensuWebhook
  REDIS_KEY_PREFIX = 'sensu'

  def initialize(payload)
    @payload = payload
  end

  def process
    service_id = @payload['key']

    case @payload['event']['action']
      when 'create'
        redis_message = "#{service_id}: #{@payload['event']['check']['output']}"
        Alert.create(redis_key, { message: redis_message } )
      when 'resolve'
        Alert.destroy(redis_key)
    end

    true
  end

  private

  def redis_key
    "#{REDIS_KEY_PREFIX}:#{@payload['key']}"
  end
end