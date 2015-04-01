class HipchatWebhook
  REDIS_KEY_PREFIX = 'hipchat'

  def initialize(payload)
    @payload = payload
  end

  def process
    case @payload['room']
    when '2nd_line'
      case @payload['message']
      when 'incident on'
        Flag.create(redis_key)
      when 'incident off'
        Flag.destroy(redis_key)
      end
    end
  end

  private

  def redis_key
    "#{REDIS_KEY_PREFIX}:incident_mode"
  end

end