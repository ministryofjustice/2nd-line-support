# 2nd-line-support Dashboard

[![Build Status](https://travis-ci.org/ministryofjustice/2nd-line-support.svg)](https://travis-ci.org/ministryofjustice/2nd-line-support)

This is a Heroku app which aggregates data from a few sources in order to
provide a useful feed to the people currently on 2nd line support.

We have written a tiny custom dashboard rather than using something like
Geckoboard or Dashing as they don't work very well for a vastly changing number
of items to display

The display part works by simply reading all keys out of redis and displaying
them. Redis is populated by various sources that either push or poll. The duty roster, "On duty", is populated from the [Support Rota spreadsheet sheet "dashboard widgets"](https://docs.google.com/a/digital.justice.gov.uk/spreadsheets/d/<spreadsheet-key>/pub?single=true&gid=<spreadsheet-gid>). The refresh interval for this can be configured in SupportApp in app.rb.


## Instalation

Once you have cloned the project make sure that you have Redis installed. (you can do this by start running the Redis Server)

	redis-server /usr/local/etc/redis.conf

If its not installed, use the following code and re-run it

    brew install redis

Install the gems with bundler:

	bundle install

If you don't have bundler installed, then do

	gem install bundler

Make sure that all the tests are passing by writing,

    rspec

Set up your env variables by following the instructions on the 2nd line config repo.

	e.g. source ../2nd-line-support-config/config/env

then just run:

	shotgun


## Sensu Checks

Not all sensu checks should go to 2nd line support (as they are too noisy right
now) so only selected checks with the "level-2-support" handler enabled will
push to sensu.

See [the PR adding it](https://github.com/ministryofjustice/sensu-formula/pull/60)
for a bit more info on that yet. This isn't live anywhere yet.


## PagerDuty Checks

Every 10 seconds, the app asks pagerduty if there any alerts.

Services and settings can be configured in app.rb


##Incidents reported by mails to incidents@digital.justice.gov.uk

This email address is mapped to incidents@ministryofjustice.zendesk.com.

Emails received on this address will trigger a PagerDuty alert by the following mechansm:

- The Zendesk trigger "PagerDuty Trigger" is fired on receipt of the mail, which will execute the "Notify PagerDuty of Incoming Mail" target
- The Zendesk target "Notify PagerDuty" of incoming mail sends a mail to PagerDuty
- The PagerDuty service "Create Incident from Zendesk mail" will create an incident and notify duty personnel in the normal manner
- The PagerDuty Hipchat webhook will post a message to our Hipchat room.

Resolving the ticket in Zendesk will also resolve the incident in PagerDuty and send an issue resolved message to Hipchat


## Endpoints:

Check `app.rb` for details


## Running application tests locally

To run specs with guard during development:

    bundle exec guard
