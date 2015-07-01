require 'json'

require_relative '../app'
require_relative '../models/redis_struct'
require_relative '../services/whos_on_duty'

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

class DutyRoster
  def self.default
    new(SupportApp.duty_roster_google_doc_refresh_interval)
  end

  def stale?
    Time.now > Time.parse(@members.last_update) + @refresh_interval
  end

  def invalid?
    members.nil? || members.empty?
  end

  def update
    refresh! if invalid? || stale?
  end

  def refresh!
    retrieved_data = WhosOnDuty.list
    @members.update(retrieved_data) if retrieved_data.any?
  end

  def clear!
    @members.destroy_all
  end

  def members
    @members.list
  end

  def manager
    members.find { |p| p[:rule] == 'duty_manager' }
  end

  private

  def initialize(refresh_interval)
    @refresh_interval = refresh_interval
    @members          = DutyRosterMembers
  end
end
