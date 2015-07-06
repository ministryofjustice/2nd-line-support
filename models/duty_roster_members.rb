class DutyRosterMembers < RedisStruct
  DATA_KEY    = 'members'.freeze
  V2_DATA_KEY = 'v2members'.freeze
  TIME_KEY    = 'update_time'.freeze

  def self.update(data)
    redis.set(cache_key(DATA_KEY), data.to_json)
    redis.set(cache_key(V2_DATA_KEY), format_data_for_v2(data).to_json)
    redis.set(cache_key(TIME_KEY), Time.now)
  end

  def self.list
    struct = fetch(DATA_KEY)
    struct.value && JSON.parse(struct.value, symbolize_names: true)
  end

  def self.v2_list
    struct = fetch(V2_DATA_KEY)
    struct.value && JSON.parse(struct.value, symbolize_names: true)
  end

  def self.last_update
    fetch(TIME_KEY).value
  end

  def self.destroy_all
    super("#{key_prefix}:*")
  end

  

  def self.format_data_for_v2(data)
    v2_data = {}
    data.each do |member|
      case member[:rule]
      when 'webop'
        add_web_ops_member(v2_data, member)
      when 'dev'
        add_dev_member(v2_data, member)
      end
    end
    v2_data
  end


  def self.add_web_ops_member(v2_data, member)
    v2_data['web_ops'] = member[:name]
  end

  def self.add_dev_member(v2_data, member)
    if v2_data.key?('dev_2')
      v2_data['dev_3'] = member[:name]
    elsif v2_data.key?('dev_1')
      v2_data['dev_2'] = member[:name]
    else
      v2_data['dev_1'] = member[:name]
    end
  end

  def self.key_prefix
    'duty_roster'
  end

end
