require 'csv'
require_relative 'people'

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

      managers = People.new.fetch_irms
      managers = managers.any? ? managers : [{"name" => members[4], "contact_methods" => []}]
      duty_managers = parse_duty_managers(managers)

      return webops + devs + duty_managers
    rescue
      []
    end
  end

  def self.build_row(person, rule, has_phone, contact_methods=[])
    {
      person: person,
      rule: rule,
      has_phone: has_phone,
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
      address: self.format_contact_method_address(contact_method['type'], contact_method['address']),
      label: contact_method['label'],
    }
  end

  def self.format_contact_method_address(type, address)
    if (Float(address) rescue false) and !address.start_with?('0')
      address = address.rjust(11, '0').unpack('A3A4A4').join(' ')
    end
    address
  end

  def self.data_url
    key = SupportApp.duty_roster_google_doc_key
    gid = SupportApp.duty_roster_google_doc_gid
    "https://docs.google.com/spreadsheet/pub?key=#{key}&single=true&gid=#{gid}&output=csv"
  end
end
