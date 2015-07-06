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


  def self.formatted_hash
    full_hash = self.list
    result =
      {
        irm: "Dave Rogers",
        irm_telephone: "01234-567890",
        dev_1: " David Cameron",
        dev_2: "George Osborne",
        web_ops: "Angela Merkel",
        ooh_1: "Alexis Tsipras",
        ooh_2: "Yanis Varoufakis"
      }
    result
  end

  private

  def self.key_prefix
    'duty_roster'
  end


end
