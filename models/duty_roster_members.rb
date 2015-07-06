class DutyRosterMembers < RedisStruct
  DATA_KEY = 'members'.freeze
  TIME_KEY = 'update_time'.freeze

  def self.update(data)
    redis.set(cache_key(DATA_KEY), data.to_json)
    redis.set(cache_key(TIME_KEY), Time.now)
  end

  def self.list
    struct = fetch(DATA_KEY)
    struct.value && JSON.parse(struct.value, symbolize_names: true)
  end

  def self.last_update
    fetch(TIME_KEY).value
  end

  def self.destroy_all
    super("#{key_prefix}:*")
  end

  private

  def self.key_prefix
    'duty_roster'
  end
end
