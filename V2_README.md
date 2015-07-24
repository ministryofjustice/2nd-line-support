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
    'status_bar_status'  =>  'ok' | 'warn' | 'fail',
    'duty_roster' => [
            {'name' => 'Joe Blogs', 'role' => 'dev_1' },
            {'name' => 'Joe Blogs', 'role' => 'dev_2' },
            {'name' => 'Joe Blogs', 'role' => 'ooh_1' },
            {'name' => 'Joe Blogs', 'role' => 'ooh_2' },
            {'name' => 'Joe Blogs', 'role' => 'web_ops' },
            {'name' => 'Joe Blogs', 'role' => 'irm', 'telephone' => '123456789' }
    ],
    'services' => an array of sentences like: 'AWS is DOWN'
    'services_status' => 'ok' | 'warn' | 'fail'
    'number_of_alerts' =>  '3'
    'tools_status' => 'ok' | 'warn' | 'fail'
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

The EventCollector runs every 30 seconds (set in the environment config as :event_collector_refresh_time_in_seconds) or so and gathers this data (every hour for the google docs) and writes it to a REDIS database.

The v2-admin action on the controller just pulls the stuff out of REDIS and formats it into the JSON response.

The EventCollector daemon can be started via the rake task:

    rake collector:daemon:start

This will create a event\_collector.pid file. Status (running or not) can be monitored with:

    rake collector:daemon:start

To stop the daemon:

    rake: collector:daemon:stop

TODO:
 - provide a v2 dashboard endpoint for non admin users - just to show duty roster and events (details to be confirmed with Dave Rogers)
 - remove all the old controller endpoints
 - Think about refactoring all the RedisStruct objects to use RedisClient.










