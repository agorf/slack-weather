# slack-weather

A bunch of [Ruby][] scripts that scrape [Meteo.gr][] for weather data
(temperature, humidity, wind, dust) and post it as a nicely-formatted message to
a [Slack][] channel.

[Ruby]: https://www.ruby-lang.org/en/
[Meteo.gr]: http://meteo.gr/
[Slack]: https://slack.com/

## Installation

Clone the repo and install the necessary [Gems][] using [Bundler][]:

```sh
git clone https://github.com/agorf/slack-weather.git
cd slack-weather/
bundle install
```

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

```sh
bundle exec ruby slack_poster.rb
```

You can run this with [cron][] e.g. once per day at 5 pm:

```
0 17 * * * bundle exec ruby slack_poster.rb
```

[cron]: https://en.wikipedia.org/wiki/Cron

## License

[MIT][]

[MIT]: https://github.com/agorf/slack-weather/blob/master/LICENSE.txt

## Author

[Angelos Orfanakos](https://agorf.gr/contact/)
