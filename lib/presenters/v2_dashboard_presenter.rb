require 'json'

class V2DashboardPresenter


  def initialize
    # TODO we load data with the dummy data to start off with, and then replace it with real data
    # as we implemnt the features.
    # we can get rid of the line below once we've done everything.
    @data = YAML::load_file(File.join(__dir__, '../../config/dummy_data.yml'))
    @data['duty_roster'] = DutyRosterMembers.formatted_hash


  end



  def to_json
    @data.to_json
  end

end