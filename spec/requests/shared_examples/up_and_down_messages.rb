shared_examples 'for down message' do
  it 'creates a new alert' do
    expect(Alert.exists?(new_alert_key)).to be true
  end

  it 'the alert contains message identifying the problem with the service' do
    expect(Alert.fetch(new_alert_key).message).to eql("#{service_id}: DESCRIPTION")
  end

  it 'returns 201 success' do
    expect(last_response).to be_created
  end
end

shared_examples 'for up message' do
  it 'removes the existing alert' do
    expect(Alert.exists?(existing_alert_key)).to be false
  end

  it 'returns 201 success' do
    expect(last_response).to be_created
  end
end