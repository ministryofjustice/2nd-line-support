require 'bcrypt'

module Auth
  extend self
  include BCrypt

  def valid_credentials?(user, pass)
    Password.new(SupportApp.app_user) == user && SupportApp.app_pass == pass
  end  
end