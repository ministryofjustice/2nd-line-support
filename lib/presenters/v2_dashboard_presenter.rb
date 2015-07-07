require 'json'

class V2DashboardPresenter


  def initialize
    @redis = Redis.new(:url => ENV["REDISCLOUD_URL"])
    # TODO we load data with the dummy data to start off with, and then replace it with real data
    # as we implemnt the features.
    # we can get rid of the line below once we've done everything.
    @data = YAML::load_file(File.join(__dir__, '../../config/dummy_data.yml'))
    collect_duty_roster_data
    collect_irm
  end



  def to_json
    @data.to_json
  end

  private

  def collect_duty_roster_data
    @data['duty_roster'] = DutyRosterMembers.v2_list
    ooh_members = JSON.parse(@redis.get('ooh:members'))
    ooh_members.each_with_index do |member, i|
      @data['duty_roster']["ooh_#{i + 1}"] = member['name']
    end
  end


  def collect_irm
    irm = JSON.parse(@redis.get('duty_roster:v2irm'))
    @data['duty_roster']['irm'] = irm['name']
    @data['duty_roster']['irm_telephone'] = irm['telephone']
  end

end