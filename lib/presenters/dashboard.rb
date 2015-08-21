require 'ostruct'

require_relative '../../models/duty_roster.rb'
require_relative '../../models/flag.rb'
require_relative '../../models/alert.rb'

require_relative '../../services/whos_on_duty'
require_relative '../../services/whos_out_of_hours'
require_relative '../../services/zendesk'
require_relative '../../services/support_hours'

module Presenters
  module Dashboard
    extend self

    def admin(duty_roster)
      build_from({
        whos_on_duty:            duty_roster.members,
        whos_out_of_hours:       WhosOutOfHours.list,
        incidents_in_past_week:  zendesk.incidents_for_the_past_week,
        we_are_in_support_hours: SupportHours.support_hours?
      })
    end

    def default(duty_roster)
      build_from({
        whos_on_duty: duty_roster.manager,
        incidents_in_past_week: zendesk.incidents_for_the_past_week
      })
    end

    private

    def build_from(data_h)
      data = default_data.merge(data_h)

      OpenStruct.new(data)
    end

    def default_data
      {
        alerts:           Alert.fetch_all,
        problem_mode:     Flag.exists?('hipchat:problem_mode'),
        active_incidents: zendesk.active_incidents
      }
    end

    def zendesk
      # Don't be tempted to momoize this, for example @zendest ||= Zendesk.new - it will
      # cache results and therefore return incorrect values
      Zendesk.new
    end
  end
end
