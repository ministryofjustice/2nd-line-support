# this allows you to open up a rails-style console with all the models
# loaded:

# e.g. irb -r console.rb
require 'pp'
require 'ap'

Dir.chdir(File.dirname(__FILE__))

require './app.rb'
%w{ lib presenters models services }.each do |subdir|
  Dir["#{subdir}/**/*.rb"].each { |f| require f }
end

Excon.defaults[:ssl_verify_peer] = false

