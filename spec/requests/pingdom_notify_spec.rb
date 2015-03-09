require 'spec_helper'

describe 'GET /pingdom_notify/:service_id' do
  def app
    SupportApp
  end

  it 'returns 200 error' do
    get '/pingdom_notify/pvb'

    expect(last_response).to be_ok
  end
end