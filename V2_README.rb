DASHBOARD V2 Admin
===================


Dummy controller to give Faz something to work on:

Action name should be GET '/v2-admin'.
It should populate an instance variable @dashboard a JSON hash:


  'status_bar_text'  =>   '3 incidents in past week',
  'status_bar_color'  =>  'red' | 'amber' | 'green',
  'duty_roster' => {
      'irm' =>
      'irm_telephone'
      'dev_1'
      'dev_2'
      'web_ops'
      'ooh_1'
      'ooh_1'
    },
  'services' => an array of sentences like: 'AWS is DOWN'
  'services_color' => 'red' | 'none'
  'tools' =>  '3 alerts'
  'tools_color' => 'red' | 'none'
  'tickets' [
                {
                  'type' => 'problem' | 'incident',
                  'ticket_no' => nnnnn,
                  'text' =>  some text
                }
              ]
            }


  Put all of this in to a yaml file, and just generate it from that.





  Collection of Data into redis database:
  =======================================

  * Call PagerDutyAlerts.check alerts - this will write incidents for the services defined in SupportApp.pager_duty_services