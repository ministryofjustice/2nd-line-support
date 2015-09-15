require 'spec_helper'
require 'shared_examples_of_stubbed_api_requests'

describe 'Discover who is on duty for IRAT' do
  include_examples "stubbed api requests"

  let(:the_team) do
    ['Benedetto Lo Giudice', 'Todd Tyree',
     'Lukasz Raczylo', 'Edward Andress']
  end

  context 'As an authenticated dashboard user' do
    feature 'I look at /admin during support working hours ' do

      before do
        Timecop.freeze(Time.local(2015, 9, 2, 13)) do
          reset_roster!
          basic_auth
          visit '/admin'
        end
      end

      scenario 'I see who the primary webop is' do
        expect(page.body).to have_selector('.primary-webop', text: 'Primary Webop')
        expect(page.body).to have_selector('.primary-webop', text: 'Benedetto Lo Giudice')
      end

      scenario 'I see who else is on the support team that day' do
        [the_team - ['Benedetto Lo Giudice']].flatten.each do |member|
          expect(page.body).to have_content(member)
        end
      end

      scenario 'I see who the duty manager is' do
        expect(page.body).to have_selector('.duty_manager', text: 'Duty Manager')
        expect(page.body).to have_selector('.duty_manager', text: 'Stuart Munro')
      end

      scenario 'I see who is on duty tonight' do
        expect(page.body).to have_content('On Duty Tonight')
        expect(page.body).to have_selector('#out-of-hours', text: 'Stuart Munro')
      end

      scenario 'I see when the rota changes from working hours to out of hours' do
        expect(page.body).to have_content('from 17:00')
      end

    end
  end

  feature 'I look at /admin out of hours' do

    before do
      Timecop.freeze(Time.local(2015, 9, 2, 20)) do
        reset_roster!
        basic_auth
        visit '/admin'
      end
    end

    scenario 'The dashboard does not show the in hours workers' do
      expect(page.body).not_to have_content('On Duty Tonight')
      the_team.each do |member|
        expect(page.body).not_to have_content(member)
      end
    end

    # TODO: IRPagerduty needs some work to work out the exact format
    # of the JSON the API returns. For now, this is sufficient as it
    # has been manually tested with the real feed (shouldn't show Stuart
    # twice).
    scenario 'I see who is on duty right now' do
      expect(page.body).to have_content('Stuart Munro', count: 2)
    end

    scenario 'I see when out of hours support finishes' do
      expect(page.body).to have_content('Ends at 22:59')
    end

  end


  feature 'I look at /admin over the weekend, which is out of hours' do

    before do
      Timecop.freeze(Time.local(2015, 9, 5, 13)) do
        reset_roster!
        basic_auth
        visit '/admin'
      end
    end

    scenario 'The dashboard does not show the in hours workers' do
      expect(page.body).not_to have_content('On Duty Tonight')
      the_team.each do |member|
        expect(page.body).not_to have_content(member)
      end
    end

    scenario 'I see who is on duty right now' do
      expect(page.body).to have_content('Stuart Munro', count: 2)
    end

    scenario 'I see when out of hours support finishes' do
      expect(page.body).to have_content('Ends at 22:59')
    end
  end

  feature 'I look at /admin during the no-support period' do

    before do
      Timecop.freeze(Time.local(2015, 9, 3, 23)) do
        reset_roster!
        basic_auth
        visit '/admin'
      end
    end

    scenario 'The dashboard does not show the in hours workers' do
      expect(page.body).not_to have_content('On Duty Tonight')
      the_team.each do |member|
        expect(page.body).not_to have_content(member)
      end
    end

    scenario 'I do not see who is on duty out of hours' do
      expect(page.body).not_to have_content('Stuart Munro')
    end

    scenario 'I see when support resumes' do
      expect(page.body).to have_content('Support hours resume at 10:01')
    end

  end

  context 'I am not signed in' do
    before do
      Timecop.freeze(Time.local(2015, 9, 2, 20)) do
        reset_roster!
        visit '/'
      end
    end

    feature 'I look at / at any time' do
      scenario 'I see who the current duty manager is' do
        expect(page.body).to have_content('Stuart Munro')
      end

      scenario 'I cannot see any of the other support memebers' do
        the_team.each do |member|
          expect(page.body).not_to have_content(member)
        end
      end
    end
  end
end
