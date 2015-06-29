require 'json'
require 'date'
require 'httparty'
require 'uri'

require_relative 'ir_pagerduty'

module WhosOutOfHours
  extend self 

  def list
    scheduled_persons.map(&:to_h)
  end

  private_class_method

  def scheduled_persons
    #
    # NOTE: add each person in each schedule to the one list
    # The first schedule is used to store the "primary" support member
    # and second schedule id to indicate the "secondary" support member
    # for display purposes only (i.e. the phone-icon) the primary is
    # treated webop and secondary as dev
    #
    persons = 
      schedule_ids
        .map(&method(:persons_from_sid))
        .flatten

    persons.any? ? persons : [ Person.missing ]
  end
  
  def persons_from_sid(sid)
    pagerduty.fetch_todays_schedules_names(sid).map do |name|
      Person.new(
        name, 
        (sid == schedule_ids.first) ? 'webop' : 'dev'
      )
    end
  end

  def pagerduty
    @pagerduty ||= IRPagerduty.new
  end

  def schedule_ids
    @schedule_ids ||= SupportApp.pager_duty_schedule_ids.split(',')
  end

  Person = Struct.new(:name, :rule) do
    def self.missing
      self.new('not available', 'bad')
    end

    def to_h
      {
        name:      name,
        rule:      rule,
        has_phone: has_phone?
      }
    end

    def has_phone?
      !!(name && rule) && rule != 'bad'
    end
  end
end
