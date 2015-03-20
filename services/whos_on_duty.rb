require 'csv'

module WhosOnDuty

  def self.list
    response = Excon.get(data_url, headers: { 'Accept' => 'text/csv' } )

    begin
      members = CSV.parse(response.body)[1][1..-1]
      members = members.compact.sort.map(&:strip)
      members.is_a?(Array) ? members : []
    rescue
      []
    end
  end

  def self.data_url
    key = '1j28ELnPgKi0fO6io6aQd-ROUlbXBaiEo63ct4WQVtUQ'
    gid = '1997221201'
    "https://docs.google.com/spreadsheet/pub?key=#{key}&single=true&gid=#{gid}&output=csv"
  end
end
