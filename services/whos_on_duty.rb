require 'csv'

module WhosOnDuty

  def self.list
    response = Excon.get(data_url, headers: { "Accept" => "text/csv" } )

    begin
      list = CSV.parse(response.body).first.map(&:strip)
      if list.is_a?(Array)
        list
      else
        raise list.inspect
      end
    rescue
      []
    end
  end

  def self.data_url
    key = '1HOQMB1zyTaWzbHOS54NzqWUcT3umxAUwwzQAQlDy3a0'
    "https://docs.google.com/spreadsheet/pub?key=#{key}&single=true&gid=0&output=csv"
  end
end