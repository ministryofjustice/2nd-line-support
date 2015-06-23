class DutyRoster
  attr_accessor :members, :last_update

  def initialize(refresh_interval) 
    @refresh_interval = refresh_interval
  end

  def stale?
    Time.now > @last_update + @refresh_interval
  end

  def invalid?
    @members.nil? || @members.is_a?(Hash)
  end

  def update
    retrieved_data = WhosOnDuty.list
    @members       = retrieved_data if retrieved_data.any?
    @last_update   = Time.now
  end

  def clear!
    @members = nil
  end
end



