require_relative 'ir_pagerduty'
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

  def fetch_managers
    pdm = pagerduty_managers
    return {} if pdm.empty?
    Builder::Manager.hash(pdm)
  end
end
