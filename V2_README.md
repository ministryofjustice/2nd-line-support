# V2 Dashboard


A new dashboard, known as the V2 dashboard has been designed with the 
following layout.

    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    +                                            +                           +  
    +                                            +                           +  
    +                                            +                           +  
    +                                            +        DUTY ROSTER        +  
    +                                            +        DETAILS            +  
    +      ZENDESK TICKETS                       +                           +  
    +                                            +                           +  
    +                                            +                           +  
    +                                            +                           +  
    +                                            +                           +  
    +                                            +                           +  
    +                                            +                           +  
    +                                            +                           +  
    ++++++++++++++++++++++++++++++++++++++++++++++                           +
    +   SERVICES        +    EXTERNAL TOOLS      +                           +
    +   DOWN            +    DOWN                +                           +
    +                   +                        +                           +
    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    +                            STATUS BAR                                  +
    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


The data to populate this dashboard is provided as a json structure as follows:

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
    'number_of_alerts' =>  '3'
    'tools_color' => 'red' | 'none'
    'tickets' [
                  {
                    'type' => 'problem' | 'incident',
                    'ticket_no' => nnnnn,
                    'text' =>  some text
                  }
                ]
              }


  The data is sourced from the following external services:

  - PagerDuty: 
    - alerts
    - On duty Incident Resonse Manager

  - Zendesk:
    - Open Tickets (incidents or Problems)
    - No of Incidents in past week

  - Google Docs
    - Duty Roster

The EventCollector runs every 20 seconds or so and gathers this data (every hour for the google docs) and writes it to a REDIS database.

The v2-admin action on the controller just pulls the stuff out of REDIS and formats it into the JSON response.




TODO:
 - provide a v2 dashboard endpoint for non admin users - just to show duty roster and events (details to be confirmed with Dave Rogers)
 - daemonize EventCollector.  Currently it runs just once via a rake command ```rake collector:run_once```.
 - remove all the old controller endpoints
 - Think about refactoring all the RedisStruct objects to use RedisClient.  









