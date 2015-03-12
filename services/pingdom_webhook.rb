class PingdomWebhook
  REDIS_KEY_PREFIX = 'pingdom'

  def initialize(service_id)
    @service_id = service_id
  end

  def process(message)
    if message =~ /^{/
      process_json(message)
    else
      process_old(message)
    end
  end

  private

  def redis_key
    "#{REDIS_KEY_PREFIX}:#{@service_id}"
  end

  def process_json(message)
    begin
      json = JSON.parse(message)

      case json['action']
        when 'assign'
          redis_message = "#{@service_id}: #{json['description']}"
          Alert.create(redis_key, { message: redis_message } )
        when 'notify_of_close'
          Alert.destroy(redis_key)
      end

      true
    rescue
      false
    end
  end

  def process_old(message)
    matches = message.match(/^PingdomAlert (UP|DOWN):.*?\(([^\)]*)\)/)
    if matches
      case matches[1]
        when 'DOWN'
          redis_message = "#{@service_id}: #{matches[2]}"
          Alert.create(redis_key, { message: redis_message } )
        when 'UP'
          Alert.destroy(redis_key)
      end

      true
    else
      false
    end
  end
end