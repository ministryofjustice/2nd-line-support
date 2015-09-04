require 'csv'
require_relative 'ir_pagerduty'
require_relative '../lib/support_rota_doc'
require_relative '../lib/builder'
require_relative '../services/floatschedule_rota'

module WhosOnDuty
  extend self

  def list
    source.fetch_data
    @list = []

    @list = [
      source.primary_webop, source.secondary_webop,
      source.primary_dev, source.secondary_dev,
      fetch_managers
    ].flatten.reject(&:empty?)
      []
    else
      webops + devs + duty_managers
    end

  rescue GoogleDoc::ReadAccessError
    []
  end

  private

  def source
    @source ||= FloatscheduleRota.new
  end

  def pagerduty
    @pagerduty ||= IRPagerduty.new
  end

  def pagerduty_managers
    pagerduty.fetch_todays_schedules_users(SupportApp.pager_duty_irm_schedule_id)
  end

  # Fall back to google doc if no IRM in PagerDuty
  def fetch_managers
    managers = pagerduty_managers
    managers = managers.any? ? managers : source.duty_managers(:current)
  end
end
