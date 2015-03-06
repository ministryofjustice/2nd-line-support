# 2nd-line-support Dashboard

This is a Heroku app which aggregates data from a few sources in order to
provide a useful feed to the people currently on 2nd line support.

We have written a tiny custom dashboard rather than using something like
Geckoboard or Dashing as they don't work very well for a vastly changing number
of items to display

The display part works by simply reading all keys out of redis and displaying
them. Redis is populated by various sources that either push or poll (sensu
pushes some alerts to us, we poll pingdom for status)

## Sensu Checks

Not all sensu checks should go to 2nd line support (as they are too noisy right
now) so only selected checks with the "level-2-support" handler enabled will
push to sensu.

See [the PR adding it](https://github.com/ministryofjustice/sensu-formula/pull/60)
for a bit more info on that yet. This isn't live anywhere yet.

## Pingdom

Due to limitations in the herkou scheduling feature (it won't go more frequent
than once every 10 minutes) we are using Pingdom to hit an endpoint every
minute that then looks for any check tagged 'level-2-support' and if it's down
we will put an entry in redis

## Environment Variables

The app expects the following environment/configuration variables to be enabled:

	* PINGDOM_USERNAME
	* PINGDOM_API_KEY
	* PINGDOM_PASSWORD


## Endpoints:

Check `web.rb` for details


