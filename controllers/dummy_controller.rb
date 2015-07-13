require 'json'

class SupportApp < Sinatra::Application
  get '/dummy' do
    File.read('dummy.json')
  end
end
