
require_relative 'services/event_collector'

puts ">>>>>>>>>>>>>>>> DEBUG starting event collector as daemon    #{__FILE__}::#{__LINE__} <<<<<<<<<<"
EventCollector.new.run_as_daemon