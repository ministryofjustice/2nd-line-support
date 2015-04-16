require 'csv'

module WhosOnDuty

  def self.list
    begin
      response = Excon.get(data_url, headers: { 'Accept' => 'text/csv' } )
      csv_body = CSV.parse(response.body)
      members = csv_body[1][1..-1]
      next_week_members = csv_body[2][1..-1]

      # if not array or empty => return {}
      if !members.is_a?(Array) || members.length <= 0
        return {}
      end

      # split devs into dev1 (with phone) and other devs
      # dev1 is the first dev started this week who is on duty
      # next week as well
      dev1 = nil
      other_devs = []
      for dev in members[1..3].compact.sort.map(&:strip)
        if next_week_members.include?(dev) && dev1.nil?
          dev1 = dev
        else
          other_devs.push(dev)
        end
      end

      members = {
        'webop': members[0],
        'dev1': dev1,
        'other_devs': other_devs,
        'duty_manager': members[4]
      }
    rescue
      {}
    end
  end

  def self.data_url
    key = SupportApp.duty_roster_google_doc_key
    gid = SupportApp.duty_roster_google_doc_gid
    "https://docs.google.com/spreadsheet/pub?key=#{key}&single=true&gid=#{gid}&output=csv"
  end
end
