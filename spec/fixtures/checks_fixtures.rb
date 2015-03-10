def expected_check_fixtures
  {
    "checks" =>    [
      {
        "id" => 1043334,
        "created" => 1385726197,
        "name" => "Prison visits HTTPS",
        "hostname" => "www.prisonvisits.service.gov.uk",
        "use_legacy_notifications" => false,
        "resolution" => 1,
        "type" => "http",
        "lasterrortime" => 1425040778,
        "lasttesttime" => 1425381079,
        "lastresponsetime" => 191,
        "status" => "up",
        "probe_filters" => [],
        "alert_policy" => 1363733,
        "alert_policy_name" => "PVB",
        "acktimeout" => 0,
        "autoresolve" => 0
      },
      {
        "id" => 1115998,
        "created" => 1392203381,
        "name" => "Prison visits HTTP",
        "hostname" => "www.prisonvisits.service.gov.uk",
        "use_legacy_notifications" => false,
        "resolution" => 1,
        "type" => "http",
        "lasterrortime" => 1424700365,
        "lasttesttime" => 1425381141,
        "lastresponsetime" => 1218,
        "status" => "up",
        "probe_filters" => [],
        "alert_policy" => 1363733,
        "alert_policy_name" => "PVB",
        "acktimeout" => 0,
        "autoresolve" => 0
      },
      {
        "id" => 1116081,
        "created" => 1392205758,
        "name" => "Justice Blog",
        "hostname" => "blogs.justice.gov.uk",
        "use_legacy_notifications" => false,
        "resolution" => 5,
        "type" => "http",
        "lasterrortime" => 1425381019,
        "lasttesttime" => 1425381019,
        "lastresponsetime" => 0,
        "status" => "down",
        "probe_filters" => [],
        "alert_policy" => 1363693,
        "alert_policy_name" => "Alert nobody",
        "acktimeout" => 0,
        "autoresolve" => 0
      },
      {
        "id" => 1163951,
        "created" => 1395666236,
        "name" => "Civil Claims Live",
        "hostname" => "civilclaims.service.gov.uk",
        "use_legacy_notifications" => false,
        "resolution" => 5,
        "type" => "http",
        "lasterrortime" => 1425368959,
        "lasttesttime" => 1425380977,
        "lastresponsetime" => 1156,
        "status" => "up",
        "probe_filters" => [],
        "alert_policy" => 1363666,
        "alert_policy_name" => "Civil Claims",
        "acktimeout" => 0,
        "autoresolve" => 0
      },
      {
        "id" => 1459666,
        "created" => 1419260132,
        "name" => "Prison Visits Heathcheck",
        "hostname" => "www.prisonvisits.service.gov.uk",
        "use_legacy_notifications" => false,
        "resolution" => 1,
        "type" => "httpcustom",
        "lasterrortime" => 1424700362,
        "lasttesttime" => 1425381131,
        "lastresponsetime" => 8,
        "status" => "up",
        "probe_filters" => [],
        "alert_policy" => 1363733,
        "alert_policy_name" => "PVB",
        "acktimeout" => 0,
        "autoresolve" => 0
      }
    ],
    "counts" => {
      "total" => 64, "limited" => 5, "filtered" => 5
    }
  }
end

def abbreviated_check_list
  {
    1163951 => "Civil Claims Live",
    1116081 => "Justice Blog",
    1459666 => "Prison Visits Heathcheck",
    1115998 => "Prison visits HTTP",
    1043334 => "Prison visits HTTPS"
  }
end

def json_check_result
  {
    "activeprobes" => [69],
    "results" => [
      {
        "probeid" => 69,
        "time" => 1425382511,
        "status" => "up",
        "responsetime" => 3,
        "statusdesc" => "OK",
        "statusdesclong" => "OK",
      }
    ]
  }.to_json
end

def expected_down_json
  {
    "item" => [
      {
        "text" => "<ul><li><font color='red'>Civil Claims Live DOWN</li><li><font color='red'>Prison Visits Heathcheck DOWN</li></ul>",
        "type" => 1
      }
    ]
  }.to_json
end
