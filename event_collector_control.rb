require 'daemons'

Daemons.run_proc(File.dirname(__FILE__) + '/event_collector_runner.rb') do
  loop do
    puts ">>>>>>>>>>>>>>>> DEBUG from control    #{__FILE__}::#{__LINE__} <<<<<<<<<<"
  end
end