# 2nd-line-support Dashboard

[![Build Status](https://travis-ci.org/ministryofjustice/2nd-line-support.svg)](https://travis-ci.org/ministryofjustice/2nd-line-support)

This is a Heroku app which aggregates data from a few sources in order to
provide a useful feed to the people currently on 2nd line support.

We have written a tiny custom dashboard rather than using something like
Geckoboard or Dashing as they don't work very well for a vastly changing number
of items to display

The display part works by simply reading all keys out of redis and displaying
them. Redis is populated by various sources that either push or poll (sensu
pushes some alerts to us, we poll pingdom for status). The duty roster, "On duty", is populated from the [Support Rota spreadsheet sheet "dashboard widgets"](https://docs.google.com/a/digital.justice.gov.uk/spreadsheets/d/1j28ELnPgKi0fO6io6aQd-ROUlbXBaiEo63ct4WQVtUQ/pub?single=true&gid=1997221201). The refresh interval for this can be configured in [duty\_roster\_google\_doc.json](config/duty_roster_google_doc.json).

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
    
Then open a new tab (cmd + t) and run,

	shotgun

## Sensu Checks

Not all sensu checks should go to 2nd line support (as they are too noisy right
now) so only selected checks with the "level-2-support" handler enabled will
push to sensu.

See [the PR adding it](https://github.com/ministryofjustice/sensu-formula/pull/60)
for a bit more info on that yet. This isn't live anywhere yet.

## Pingdom

Any Alerting Endpoint can call the prepared webhook: `:HOST/pingdom_webhook/:service_name`. Preferebly with `New message format`, but
`Old message format` is also supported.

## Endpoints:

Check `app.rb` for details


## Running application tests locally

To run specs with guard during development:

    bundle exec guard
