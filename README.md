# slack-weather

A bunch of [Ruby][] scripts that scrape [Meteo.gr][] for weather data
(temperature, humidity, wind, dust) and post it as a nicely-formatted message to
a [Slack][] channel.

[Ruby]: https://www.ruby-lang.org/en/
[Meteo.gr]: http://meteo.gr/
[Slack]: https://slack.com/

## Installation

Clone the repo:

```sh
git clone https://github.com/agorf/slack-weather.git
cd slack-weather/
```

If you have [Docker][], you don't need Ruby, Bundler etc. Just build the image:

```sh
docker build -t slack_weather .
```

If you don't have [Docker][], install the necessary [Gems][] using [Bundler][]:

```sh
bundle install
```

[Docker]: https://www.docker.com/
[Gems]: https://rubygems.org/
[Bundler]: https://bundler.io/

## Configuration

With environment variables:

- `SLACK_WEATHER_WEBHOOK_URL` is the [Slack][] webhook URL to post to
- `SLACK_WEATHER_CITY_ID` is the id of the city in [Meteo.gr][] (default is `12`
  for Athens)

It is also possible to define these variables in a `.env` file in the same
directory and they will be loaded automatically.

## Use

If you have [Docker][]:

```sh
SLACK_WEATHER_WEBHOOK_URL=... docker run --rm -e SLACK_WEATHER_WEBHOOK_URL slack_weather
```

If you don't:

```sh
SLACK_WEATHER_WEBHOOK_URL=... bundle exec ruby slack_poster.rb
```

You can run this with [cron][] e.g. once per day at 5 pm:

```
0 17 * * * SLACK_WEATHER_WEBHOOK_URL=... bundle exec ruby slack_poster.rb
```

[cron]: https://en.wikipedia.org/wiki/Cron

## License

[MIT][]

[MIT]: https://github.com/agorf/slack-weather/blob/master/LICENSE.txt

## Author

[Angelos Orfanakos](https://agorf.gr/contact/)
