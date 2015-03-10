class PingdomWebhook
  REDIS_KEY_PREFIX = 'pingdom'

  def initialize(service_id)
    @service_id = service_id
  end

  def process(message)
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

  private

  def redis_key
    "#{REDIS_KEY_PREFIX}/#{@service_id}"
  end
end