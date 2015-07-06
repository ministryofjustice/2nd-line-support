module RequestHandlers
  GOOGLE_DOC_URL = "https://docs.google.com/spreadsheet/pub?" 
  PAGERDUTY_URL  = "https://moj.pagerduty.com/api/v1/incidents?" 

  def googledocs_schedule_request_returns(csv_body)
    stub_get_success(
      GOOGLE_DOC_URL + "gid=testing_gid&key=testing_key&output=csv&single=true",
      csv_body,
      {
        'Accept' => 'text/csv', 
        'Host'   => 'docs.google.com:443'
      }
    )
  end

  def pagerduty_incidents_api_returns(body)
    stub_get_success(
      PAGERDUTY_URL + "service=service1,service2&status=triggered,acknowledged",
      body
    )
  end

  def pagerduty_schedule_api_returns(body)
    stub_get_success(
      moj_pagerduty_schedule_regex,
      body
    )
  end

  def pagerduty_contact_methods_api_returns(body)
    stub_get_success(
      /.*users\/.*\/contact_methods.*/,
      body
    )
  end

  def ir_success
    { 
      'users' => [
        {
          'name' => 'duty_man1', 
          'id'   => 'XXXXXX'
        }
      ]
    }.to_json
  end

  def cm_success
    {
      'contact_methods' => [
        {
          'type'         => 'phone',
          'country_code' => '44',
          'phone_number' => '1234567891',
          'address'      => '1234567891',
          'label'        => 'Work Phone'
        }
      ]
    }.to_json
  end

  def zendesk_api_returns(body)
    stub_get_success(
      /https:\/\/.*@ministryofjustice\.zendesk\.com\/api\/.*/, 
      body,
      { "Content-Type": "application/json" }
    )
  end

  private

  def stub_get_success(url, body, headers = {})
     stub_request(
      :get,
      url
    ).to_return(
      status:   200,
      headers:  headers,
      body:     body
    )
  end
end