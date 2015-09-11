class FloatscheduleRota
  attr_accessor :url, :access_key, :people

  def initialize
    @url =         'https://api.floatschedule.com/api/v1/tasks'
    @access_key =  SupportApp.float_api_key
  end

  def fetch_data
    res = Excon.get(url, headers: { 'Accept' => 'application/json', 'Authorization' => "Bearer #{access_key}" })
    @people = JSON.load(res.body)
  end

  def primary_webop
    build_role_hash('primary-webop')
  end

  def secondary_webop
    build_role_hash('webop')
  end

  def primary_dev
    build_role_hash('primary-dev')
  end

  def secondary_dev
    build_role_hash('dev')
  end

  private

  def build_role_hash(role)
    name = get_name_for_role(role)
    name.nil? ? {} : { rule: role, name: name }
  end

  def get_name_for_role(role)
    (current_tasks.select{ |t| t['task_notes'] == role }.first || {})['person_name']
  end

  def current_tasks
    tasks.select do |t|
      Date.today.to_time.between?(Date.parse(t['start_date']).to_time, Date.parse(t['end_date']).to_time)
    end
  end

  def tasks
    @tasks = people['people'].map{ |p| p['tasks'] }.flatten
  end
end
