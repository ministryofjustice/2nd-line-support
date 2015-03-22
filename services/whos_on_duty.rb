require 'csv'

module WhosOnDuty

  def self.list
    begin
      response = Excon.get(data_url, headers: { 'Accept' => 'text/csv' } )
      members = CSV.parse(response.body)[1][1..-1].compact.sort.map(&:strip)
      members.is_a?(Array) ? members : []
    rescue
      []
    end
  end

  def self.data_url
    key = JSON.parse(File.read("config/duty_roster_google_doc.json"))["key"]
    gid = JSON.parse(File.read("config/duty_roster_google_doc.json"))["gid"]
    "https://docs.google.com/spreadsheet/pub?key=#{key}&single=true&gid=#{gid}&output=csv"
  end
end
