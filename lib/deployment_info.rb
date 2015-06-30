require 'heroku-api'

module DeploymentInfo
  extend self

  def latest
    api_response   = heroku.get_releases(SupportApp.heroku_name)
    latest_release = api_response.data[:body].last

    {
      commit:      latest_release['commit'],
      update_time: Time.parse(latest_release['created_at']).getlocal,
      version:     latest_release['name']
    }
  end

  private

  def heroku
    @heroku ||= 
      Heroku::API.new(
        username: SupportApp.heroku_user,
        password: SupportApp.heroku_pass
      )
  end
end