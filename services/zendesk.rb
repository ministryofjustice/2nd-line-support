require 'zendesk2'
require 'date'

class Zendesk
  def initialize
    options = {
      :username => SupportApp.zendesk_username,
      :token => SupportApp.zendesk_token,
      :url => SupportApp.zendesk_url
    }
    @client = Zendesk2::Client.new(options)
  end

  def incidents_for_the_past_week
    incidents_group = 'Incident response and tuning'
    @client.tickets.search(query: "created>7days group:\"#{incidents_group}\"").count
  end
end
