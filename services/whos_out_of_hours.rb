require 'json'
require 'date'
require 'httparty'
require 'uri'

module WhosOutOfHours

  def self.endpoint(sid, since_date, until_date)
    "https://#{SupportApp.pager_duty_subdomain}.pagerduty.com/api/v1/schedules/#{sid}/users/?since=#{since_date}&until=#{until_date}"
  end

  def self.build_row(person, rule, has_phone)
    {
      person: person,
      rule: rule,
      has_phone: has_phone
    }
  end

  def self.scheduled_persons
    #
    # NOTE: add each person in each schedule to the one list
    # The first schedule is used to store the "primary" support member
    # and second schedule id to indicate the "secondary" support member
    # for display purposes only (i.e. the phone-icon) the primary is
    # treated webop and secondary as dev
    #
    schedule_ids = SupportApp.pager_duty_schedule_ids.split(',')

    name_rule_pair = []
    schedule_ids.each do |sid|
      pagerduty_names(sid).each do |n|
        r = (sid == schedule_ids.first) ? 'webop' : 'dev'
        name_rule_pair.push({ name: n, rule: r })
      end
    end

    return name_rule_pair
  end

  def self.list
    persons = scheduled_persons.map do |hash|
      self.build_row( hash[:name], hash[:rule], true)
    end
  ensure
    persons.push(self.build_row("not available - see pager duty","bad", false)) unless !persons.empty?
  end

  def self.json_pagerduty_schedule_users(sid)
    #
    # NOTE: return ONLY this evening's on call people i.e. 17 to 23 hours
    #       since only this info is useful to the in hours people
    #
    dateStr = Date.today.to_s
    since_date = URI.escape(dateStr + "T17:00Z")
    until_date = URI.escape(dateStr + "T22:59Z")
    token_string = "Token token=#{SupportApp.pager_duty_token}"

    response = HTTParty.get(endpoint(sid, since_date, until_date),
                            headers: {'Content-Type' => 'application/json',
                                      'Authorization' => token_string
                             })

    return response.body
  end

  def self.pagerduty_names(sid)
    json = json_pagerduty_schedule_users(sid)
    parsed = JSON.parse(json)
    names = parsed['users'].map { |user| user['name'] }
  rescue
      []
  end

end
