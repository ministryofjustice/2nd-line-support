require 'pagerduty/full'
require 'JSON'
require 'date'  
module WhosOutOfHours

  def self.build_row(person, rule, has_phone)
    {
      person: person,
      rule: rule,
      has_phone: has_phone
    }
  end
  def self.list
    begin
    ids = SupportApp.out_of_hours_ids
    idsArray = ids.split(',')
    names = idsArray.map { |id| self.build_row(get_name(id), 'webop', true) }
    return names
    rescue
      []
    end
  end
  def self.get_name(scheduleId)
    dateStr = Date.today.to_s
    
    start_date = Date.parse(dateStr + "T01:00Z")
    end_date = Date.parse(dateStr + "T22:59Z")
    
    pd = PagerDuty::Full.new(
      apikey=SupportApp.pager_duty_token,
      subdomain=SupportApp.pager_duty_subdomain
    )

    jsonreturn = pd.Schedule.find(id = scheduleId, since_date = start_date.strftime("%FT%T%:z"), until_date = end_date.strftime("%FT%T%:z"))
	  return jsonreturn['users'][0]['name']

  end
end
