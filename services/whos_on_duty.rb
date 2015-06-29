require 'csv'
require_relative 'ir_pagerduty'
require_relative '../lib/support_rota_doc'

module WhosOnDuty
  extend self

  def list
    source.fetch_data

    webops   = parse_webops(source.webops(:current))
    devs     = parse_devs(source.devs(:current), source.devs(:next))
    managers = pagerduty_managers

    # Fall back to google doc if no IRM in PagerDuty
    managers      = managers.any? ? managers : source.duty_managers(:current)
    duty_managers = parse_duty_managers(managers)

    webops + devs + duty_managers

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

  def build_row(name, rule, has_phone, contact_methods = [])
    {
      name:            name,
      rule:            rule,
      has_phone:       has_phone,
      contact_methods: contact_methods
    }
  end

  def parse_webops(webops)
    webops.map { |webop| build_row(webop, 'webop', true) }
  end

  def parse_devs(current_devs, next_devs)
    #
    # dev with phone if:
    # - is the only dev today
    #  OR
    # - is the one who has just joined (i.e on duty next week)
    #
    current_devs.map do |dev|
      has_phone = next_devs.include?(dev) || current_devs.count == 1
      build_row(dev, 'dev', has_phone)
    end
  end

  def parse_duty_managers(managers)
    managers.map do |manager|
      build_row(
        manager['name'], 
        'duty_manager', 
        false, 
        manager['contact_methods'].map(&method(:build_contact_method_row))
      )
    end
  end

  def build_contact_method_row(contact_method)
    {
      type:    contact_method['type'],
      address: format_contact_method_address(contact_method),
      label:   contact_method['label'],
    }
  end

  def format_contact_method_address(contact_method)
    address = contact_method['address']

    if ['phone', 'SMS'].include? contact_method['type']
      address = 
      "(00) #{contact_method['country_code']} " + 
      "#{contact_method['phone_number'].reverse.gsub(/.{4}(?=.)/, '\0 ').reverse}"
    end

    address
  end
end
