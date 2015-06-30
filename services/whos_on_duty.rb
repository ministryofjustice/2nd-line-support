require 'csv'
require_relative 'ir_pagerduty'
require_relative '../lib/support_rota_doc'
require_relative '../lib/builder'

module WhosOnDuty
  extend self

  def list
    source.fetch_data

    webops        = Builder::Webop.hash(source.webops(:current))
    devs          = Builder::Dev.hash(source.devs(:current), source.devs(:next))
    duty_managers = Builder::Manager.hash(fetch_managers)

    unless webops.any? && devs.any? && fetch_managers == pagerduty_managers
      []
    else
      webops + devs + duty_managers
    end

  rescue GoogleDoc::ReadAccessError
    []
  end

  private

  def source 
    @source ||= SupportRotaDoc.default
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
