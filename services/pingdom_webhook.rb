class PingdomWebhook
  REDIS_KEY_PREFIX = 'pingdom'

  def initialize(message)
    @message = message
  end

  def process
    if @message =~ /^{/
      process_json
    else
      process_old
    end
  end

  private

  def redis_key(service_id)
    "#{REDIS_KEY_PREFIX}:#{service_id}"
  end

  def process_json
    begin
      json = JSON.parse(@message)
      service_id = json['checkname']

      case json['action']
        when 'assign'
          redis_message = "#{service_id}: #{json['description']}"
          Alert.create(redis_key(service_id), { message: redis_message } )
        when 'notify_of_close'
          Alert.destroy(redis_key(service_id))
      end

      true
    rescue
      false
    end
  end

  def process_old
    matches = @message.match(/^PingdomAlert (UP|DOWN):.*?\(([^\)]*)\)(.*)$/)
    if matches
      service_id = matches[2]

      case matches[1]
        when 'DOWN'
          redis_message = "#{service_id}: #{matches[3].strip}"
          Alert.create(redis_key(service_id), { message: redis_message } )
        when 'UP'
          Alert.destroy(redis_key(service_id))
      end

      true
    else
      false
    end
  end
end