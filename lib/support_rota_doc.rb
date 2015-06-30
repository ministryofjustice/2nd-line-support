require_relative 'google_doc'

class SupportRotaDoc < GoogleDoc
  DEV_REGEXP = /\bdev\b/i
  WOP_REGEXP = /\bweb ops\b/i
  MGR_REGEXP = /\bduty support manager\b/i

  def self.default
    key = SupportApp.duty_roster_google_doc_key
    gid = SupportApp.duty_roster_google_doc_gid

    new(key, gid)
  end

  def devs(period)
    names_matching(DEV_REGEXP, period)
  end

  def webops(period)
    names_matching(WOP_REGEXP, period)
  end

  def duty_managers(period)
    names_matching(MGR_REGEXP, period)
  end

  private

  def names_matching(regexp, period)
    case period
    when :current
      source = current_h
    when :next
      source = next_week_h
    else
      raise ArgumentError, 'period must be either :current or :next'
    end

    source.select { |role, name| role =~ regexp }.values.compact
  end

  def current_h
    body[0].to_h
  end

  def next_week_h
    body[1].to_h
  end
end