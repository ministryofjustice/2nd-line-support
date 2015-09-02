require 'spec_helper'

feature 'As any user' do

  scenario 'How long until the dashboard next refreshes?' do

  end

end

context 'I am signed in' do

  feature 'It is in regular support hours' do

    context '(these comes from float)' do

      scenario 'Who is the primary responder?' do

      end

      scenario  'Who else is on the team this week?' do

      end

    end

    context '(these come from pagerduty)' do

      scenario 'Who is the duty manager?' do

      end

      scenario 'Which pair of people are on the rota for tonight?' do

      end

      scenario 'What time does the rota switch to out-of-hours?' do

      end

    end

  end

  feature 'It is out of hours' do

    context '(these come from pagerduty)' do

      scenario 'Which pair of people are on duty right now?' do

      end

      scenario 'What time does the rota switch to in hours support?' do

      end

    end

  end

end

context 'I am not signed in' do

  feature 'At any time' do

    context '(this comes from pagerduty)' do

      scenario 'Who is the current duty manager?' do

      end

    end

  end

end
