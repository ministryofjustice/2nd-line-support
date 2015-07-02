require 'spec_helper'

describe DutyRoster do
  before(:each) do
    allow(SupportApp).to receive(:duty_roster_google_doc_refresh_interval_in_minutes).and_return(55)
  end

  let(:roster)            { DutyRoster.default }

  describe '.default' do
    it 'should instantiate a DutyRoster with refresh interval from SupportApp' do
      expect(roster.instance_variable_get(:@refresh_interval)).to eq 55
    end
  end


  describe '#stale?' do
    it 'should return true if time members last updated more than refresh interval minutes ago' do
      expect(DutyRosterMembers).to receive(:last_update).and_return(minutes_ago(56).to_s)
      expect(roster.stale?).to be true
    end

    it 'should return false if the time members last updated is less than refresh interval minutes ago' do
      expect(DutyRosterMembers).to receive(:last_update).and_return(minutes_ago(54).to_s)
      expect(roster.stale?).to be false
    end
  end


  describe 'clear' do
    it 'should call destroy all on members' do
      expect(DutyRosterMembers).to receive(:destroy_all)
      roster.clear!
    end
  end

  describe '#clear!' do
    it 'should call destroy_all on members' do
      roster = DutyRoster.default
      members = roster.instance_variable_get(:@members)
      expect(members).to receive(:destroy_all)
      roster.clear!
    end
  end
end

def minutes_ago(n)
  Time.now - (n * 60)
end
