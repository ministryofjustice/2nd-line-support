require 'csv'
require_relative 'ir_pagerduty'

module WhosOnDuty

  def self.list
    begin
      response = Excon.get(data_url, headers: { 'Accept' => 'text/csv' } )
      csv_body = CSV.parse(response.body)
      members = csv_body[1][1..-1]
      next_week_members = csv_body[2][1..-1]

      if !members.is_a?(Array) || members.length <= 0
        return []
      end

      webops = self.parse_webops([members[0]])

      devs = self.parse_devs(
        members[1..3].compact.sort.map(&:strip),
        next_week_members[1..3].compact.sort.map(&:strip)
      )

      managers = IRPagerduty.new.fetch_todays_schedules_users(SupportApp.pager_duty_irm_schedule_id)
      # Fall back to google doc if no IRM in PagerDuty
      managers = managers.any? ? managers : [{"name" => members[4], "contact_methods" => []}]
      duty_managers = parse_duty_managers(managers)

      return webops + devs + duty_managers
    rescue
      []
    end
  end

  def self.build_row(name, rule, has_phone, contact_methods=[])
    {
      name:            name,
      rule:            rule,
      has_phone:       has_phone,
      contact_methods: contact_methods
    }
  end

  def self.parse_webops(webops)
    webops.map {|webop| self.build_row(webop, 'webop', true)}.compact
  end

  def self.parse_devs(this_week_devs, next_week_devs)
    # dev with phone if:
    #   - is the only dev today
    #     OR
    #   - is the one who has just joined (not on duty next week)
    l = []
    for dev in this_week_devs
      has_phone = false
      if next_week_devs.include?(dev) || this_week_devs.length == 1
        has_phone = true
      end

      l.push(self.build_row(dev, 'dev', has_phone))
    end
    return l
  end

  def self.parse_duty_managers(managers)
    managers.map { |manager|
      self.build_row(manager['name'], 'duty_manager', false, manager['contact_methods'].map { |cm| self.build_contact_method_row(cm) } )
    }.compact
  end

  def self.build_contact_method_row(contact_method)
    {
        type: contact_method['type'],
        address: self.format_contact_method_address(contact_method),
        label: contact_method['label'],
    }
  end

  def self.format_contact_method_address(contact_method)
    address = contact_method['address']
    if ['phone', 'SMS'].include? contact_method['type']
      address = "(00) #{contact_method['country_code']} #{contact_method['phone_number'].reverse.gsub(/.{4}(?=.)/, '\0 ').reverse}"
    end
    address
  end

  def self.data_url
    key = SupportApp.duty_roster_google_doc_key
    gid = SupportApp.duty_roster_google_doc_gid
    "https://docs.google.com/spreadsheet/pub?key=#{key}&single=true&gid=#{gid}&output=csv"
  end
end
