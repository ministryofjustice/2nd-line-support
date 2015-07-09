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


  Put all of this in to a yaml file, and just generate it from that.


  REDIS KEYS AND DATA
  ====================


  duty_roster:update_time

  Date and time duty roster members was last collected from google docs



  duty_roster:members

  A hash of who is on call, e.g.
  [
      [0] {
                     "name" => "Niall Creech",
                     "rule" => "webop",
                "has_phone" => true,
          "contact_methods" => []
      },
      [1] {
                     "name" => "Trent Greenwood",
                     "rule" => "dev",
                "has_phone" => false,
          "contact_methods" => []
      },
      [2] {
                     "name" => "Stephen Richards",
                     "rule" => "dev",
                "has_phone" => true,
          "contact_methods" => []
      },
      [3] {
                     "name" => "Gavin Bell",
                     "rule" => "duty_manager",
                "has_phone" => false,
          "contact_methods" => [
              [0] {
                     "type" => "email",
                  "address" => "gavin.bell@digital.justice.gov.uk",
                    "label" => "Default"
              },
              [1] {
                     "type" => "phone",
                  "address" => "(00) 44 79 6645 2322",
                    "label" => "Mobile"
              }
          ]
      }
  ]



Pager Duty Incidents
====================


These are not currently written to the redis database.  They should be with the key 'pager_duty'
and should be an array of structures like this;

[
    [0] {
                              "id" => "PGZBWMS",
                 "incident_number" => 11110,
                      "created_on" => "2015-07-06T09:16:58Z",
                          "status" => "acknowledged",
                 "pending_actions" => [
            [0] {
                "type" => "unacknowledge",
                  "at" => "2015-07-06T09:48:09Z"
            },
            [1] {
                "type" => "resolve",
                  "at" => "2015-07-06T13:16:58Z"
            }
        ],
                        "html_url" => "https://moj-digital-tools.pagerduty.com/incidents/PGZBWMS",
                    "incident_key" => "8658",
                         "service" => {
                    "id" => "PT58DWM",
                  "name" => "Incident Response Zendesk Email",
              "html_url" => "https://moj-digital-tools.pagerduty.com/services/PT58DWM",
            "deleted_at" => nil
        },
               "escalation_policy" => {
                    "id" => "PJGAFET",
                  "name" => "Incident Response: Production",
            "deleted_at" => nil
        },
                "assigned_to_user" => {
                  "id" => "P1LACVM",
                "name" => "In Hours Support – Secondary",
               "email" => "matthew.mead-briggs+2ndline2@digital.justice.gov.uk",
            "html_url" => "https://moj-digital-tools.pagerduty.com/users/P1LACVM"
        },
            "trigger_summary_data" => {
                     "subject" => "Ticket (8658) : IRAT TEST SR 10:16",
                   "dedup_key" => "8658",
            "extracted_fields" => {
                "ticket_id" => "8658"
            }
        },
        "trigger_details_html_url" => "https://moj-digital-tools.pagerduty.com/incidents/PGZBWMS/log_entries/Q0QPH539S5Q1GG",
                    "trigger_type" => "email_trigger",
           "last_status_change_on" => "2015-07-06T09:18:09Z",
           "last_status_change_by" => {
                  "id" => "P1LACVM",
                "name" => "In Hours Support – Secondary",
               "email" => "matthew.mead-briggs+2ndline2@digital.justice.gov.uk",
            "html_url" => "https://moj-digital-tools.pagerduty.com/users/P1LACVM"
        },
           "number_of_escalations" => 0,
                     "assigned_to" => [
            [0] {
                    "at" => "2015-07-06T09:18:09Z",
                "object" => {
                          "id" => "P1LACVM",
                        "name" => "In Hours Support – Secondary",
                       "email" => "matthew.mead-briggs+2ndline2@digital.justice.gov.uk",
                    "html_url" => "https://moj-digital-tools.pagerduty.com/users/P1LACVM",
                        "type" => "user"
                }
            }
        ],
                   "acknowledgers" => [
            [0] {
                    "at" => "2015-07-06T09:18:09Z",
                "object" => {
                          "id" => "P1LACVM",
                        "name" => "In Hours Support – Secondary",
                       "email" => "matthew.mead-briggs+2ndline2@digital.justice.gov.uk",
                    "html_url" => "https://moj-digital-tools.pagerduty.com/users/P1LACVM",
                        "type" => "user"
                }
            }
        ],
                         "urgency" => "high"
    }
]






