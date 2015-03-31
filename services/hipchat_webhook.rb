class HipchatWebhook
  REDIS_KEY_PREFIX = 'hipchat'

  def initialize(payload)
    @payload = payload
  end

  def process
    case @payload['room']
    when '2nd Line'
      case @payload['message']
      when 'incident on' then
        redis_message = true
        # Alert.create(redis_key, redis_message )
      when 'incident off'
        # Alert.destroy(redis_key)
      end
    end
  end

  private

  def redis_key
    "#{REDIS_KEY_PREFIX}:#{@payload['key']}"
  end

end