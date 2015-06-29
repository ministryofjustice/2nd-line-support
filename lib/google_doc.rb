require 'csv'

class GoogleDoc
  attr_reader :url, :body

  def fetch_data
    res = Excon.get(url, headers: { 'Accept' => 'text/csv' })

    if res.status == 200
      @body = CSV.parse(res.body, headers: true)
    else
      raise ReadAccessError.new(@key, @gid)
    end
  end

  protected

  class ReadAccessError < StandardError
    def initialize(key, gid)
      super("Document GID:#{gid} was not accessible using key:#{key}")
    end
  end

  def initialize(key, gid)
    @key = key
    @gid = gid
    @url = "https://docs.google.com/spreadsheet/pub?key=#{key}&single=true&gid=#{gid}&output=csv"
  end
end