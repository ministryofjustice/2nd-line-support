require 'json'
require 'date'
require 'httparty'
require 'uri'

require_relative 'ir_pagerduty'

module WhosOutOfHours
  extend self 

  def scheduled_persons
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
      pagerduty.fetch_todays_schedules_names(sid).each do |n|
        r = (sid == schedule_ids.first) ? 'webop' : 'dev'
        name_rule_pair.push({ name: n, rule: r })
      end
    end

    return name_rule_pair
  end

  def list
    persons = scheduled_persons.map do |hash|
      self.build_row( hash[:name], hash[:rule], true)
    end
  ensure
    persons.push(self.build_row("not available - see pager duty","bad", false)) unless !persons.empty?
  end

  private_class_method

  def build_row(person, rule, has_phone)
    {
      person: person,
      rule: rule,
      has_phone: has_phone
    }
  end

  def pagerduty
    @pagerduty ||= IRPagerduty.new
  end
end
