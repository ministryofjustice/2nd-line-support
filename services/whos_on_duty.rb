require 'csv'

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

      duty_managers = self.parse_duty_managers([members[4]])

      return webops + devs + duty_managers
    rescue
      []
    end
  end

  def self.build_row(person, rule, has_phone)
    {
      person: person,
      rule: rule,
      has_phone: has_phone
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
    managers.map { |manager| self.build_row(manager, 'duty_manager', false) }.compact
  end

  def self.data_url
    key = SupportApp.duty_roster_google_doc_key
    gid = SupportApp.duty_roster_google_doc_gid
    "https://docs.google.com/spreadsheet/pub?key=#{key}&single=true&gid=#{gid}&output=csv"
  end
end
