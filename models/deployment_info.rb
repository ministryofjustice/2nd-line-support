require 'heroku-api'

module DeploymentInfo
  extend self

  def show

  end

  private_class_method

  def heroku
    @heroku ||= 
      Heroku::API.new(
        username: SupportApp.heroku_user,
        password: SupportApp.heroku_pass
      )
  end
end