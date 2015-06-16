require 'zendesk_api'

INCIDENTS_IN_PAST_WEEK =
  'type:ticket ticket_type:incident created>"7 days ago" ' +
  'group:"Incident Response"'.freeze

class Zendesk
  def initialize
    @client = ZendeskAPI::Client.new do |config|
      config.username = SupportApp.zendesk_username
      config.token = SupportApp.zendesk_token
      config.url = SupportApp.zendesk_url
    end
  end

  def incidents_for_the_past_week
    @client.search(:query => INCIDENTS_IN_PAST_WEEK).count
  end
end
