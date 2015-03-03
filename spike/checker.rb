require 'pp'
require File.expand_path(File.dirname(__FILE__) + '/../models/pingdom_api.rb')



# PingdomApi.new.record_alert('plugin', 'key', 'Many years ago in a galaxy far, far away')
# PingdomApi.new.record_alert('pingdom', 'Civil Claims', 'Service Down')
# PingdomApi.new.record_alert('sensu', 'Prison Visit Bookings', 'Free diskspace < 5%')
# PingdomApi.new.record_alert('sensu', 'ET Fees', 'CPU Load 5.8')

PingdomApi.new.record_alert('12455', {alert_id: 12455, alert_type: 'pingdom', app: 'Civil Claims', text: "DOWN"})
PingdomApi.new.record_alert('30488', {alert_id: 30488, alert_type: 'sensu', app: 'PVB', text: "CPU 95%"})

result = PingdomApi.new.alerts
pp result.map{|x| JSON.parse(x) }

