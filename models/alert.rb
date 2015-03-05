require 'redis'
class Alert < Struct.new(:key, :value)

  def self.fetch_all
    redis.keys("*").collect { |key| new(key,redis.get(key)) }
  end

  private

  def self.redis
    @redis ||= Redis.new(:host => ENV['REDIS_HOST'], :port => ENV['REDIS_PORT'].to_i, :db => ENV['REDIS_DB'].to_i)
  end
end
