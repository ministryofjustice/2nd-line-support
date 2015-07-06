require 'json'

require_relative '../app'
require_relative '../models/redis_struct'
require_relative '../services/whos_on_duty'
require_relative 'duty_roster_members'

class DutyRoster
  def self.default
    new(SupportApp.duty_roster_google_doc_refresh_interval)
  end

  private_class_method :new

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

  def initialize(refresh_interval)
    @refresh_interval = refresh_interval
    @members          = DutyRosterMembers
  end
end
