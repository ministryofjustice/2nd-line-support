require 'pagerduty/full'

class IRPagerduty < PagerDuty::Full

  START_OF_WORKING_DAY = 'T10:01Z'.freeze
  END_OF_WORKING_DAY   = 'T16:59Z'.freeze

  START_OF_SUPPORT_DAY = 'T17:00'.freeze
  END_OF_SUPPORT_DAY   = 'T22:59'.freeze

  def self.start_of_support_day
    Time.parse(START_OF_SUPPORT_DAY)
  end

  def self.end_of_support_day
    Time.parse(END_OF_SUPPORT_DAY)
  end

  def self.start_of_working_day
    Time.parse(START_OF_WORKING_DAY)
  end

  def self.end_of_working_day
    Time.parse(END_OF_WORKING_DAY)
  end

  def self.out_of_hours?
    time_now.between?(start_of_support_day, end_of_support_day) ||
    time_now.saturday? ||
    time_now.sunday?
  end

  def self.in_hours?
    time_now.between?(start_of_working_day, end_of_working_day) &&
    !time_now.saturday? &&
    !time_now.sunday?
  end

  def initialize
    super(SupportApp.pager_duty_token, SupportApp.pager_duty_subdomain)
  end

  def fetch_json(path, params = {})
    res = self.api_call(path, params)

    case res
      when Net::HTTPSuccess
        JSON.parse(res.body)
      else
        res.error!
    end
  end

  def fetch_irm
    schedule_id = SupportApp.pager_duty_irm_schedule_id
    self.Schedule.find(schedule_id)
  end

  def fetch_todays_schedules_users(schedule_id)
    map_schedule_users(
      :update_contact_methods,
      schedule_id,
      in_hours_start,
      in_hours_end
    )
  end

  def fetch_todays_schedules_names(schedule_id)
    map_schedule_users(
      :user_name,
      schedule_id,
      out_hours_start,
      out_hours_end
    )
  end

  private

  def self.time_now
    Time.zone.now
  end

  def map_schedule_users(method_name, schedule_id, start_time, end_time)
    self
      .Schedule
      .users(schedule_id, start_time, end_time)['users']
      .map(&method(method_name))
  rescue
    []
  end


  # This method returns all the users in an indeterminate order
  def update_contact_methods(user)
    contact_methods         = fetch_users_contact_methods(user['id'])
    user['contact_methods'] = contact_methods.select { |cm|
      SupportApp.pager_duty_contact_method_types.include? cm['type']
    }
    user
  end

  def fetch_users_contact_methods(user_id)
    fetch_json("users/#{user_id}/contact_methods")['contact_methods']
  end

  def user_name(user)
    user.fetch('name', 'N/A')
  end

  def in_hours_start
    "#{date_today}#{START_OF_WORKING_DAY}"
  end

  def in_hours_end
    "#{date_today}#{END_OF_WORKING_DAY}"
  end

  def out_hours_start
    "#{date_today}#{START_OF_SUPPORT_DAY}"
  end

  def out_hours_end
    "#{date_today}#{END_OF_SUPPORT_DAY}"
  end

  def date_today
    @date_today ||= Date.today.to_s
  end
end
