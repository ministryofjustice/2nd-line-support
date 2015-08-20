module SupportHours
  extend self
  START_HOUR = 10
  END_HOUR   = 17

  def support_hours?
    tz = ENV['TZ']
    ENV['TZ'] = 'Europe/London'
    @support_hours = Time.now.hour >= START_HOUR && Time.now.hour < END_HOUR
    ENV['TZ'] = tz
    @support_hours
  end

end
