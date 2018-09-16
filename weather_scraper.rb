require 'nokogiri'
require 'open-uri'

module SlackWeather
  class WeatherScraper
    HOURS = [3, 9, 15, 21].freeze

    CITY_ID = ENV.fetch('SLACK_WEATHER_CITY_ID', '12') # 12 is Athens

    URL = sprintf('http://meteo.gr/cf.cfm?city_id=%s', CITY_ID).freeze

    WIND_REGEX = %r{
      (?<bf>\d+)\sΜπφ\s
      (?<direction>[ΒΝ][ΑΔ]?|[ΑΔ])\s
      (?<kph>\d+)\sKm/h
      (\sΡιπές\sανέμου:\s(?<bursts>\d+))?
    }x

    CONDITIONS_REGEX = %r{
      ΚΑΘΑΡΟΣ|
      ΠΕΡΙΟΡΙΣΜΕΝΗ\sΟΡΑΤΟΤΗΤΑ|
      (ΛΙΓΑ|ΑΡΚΕΤΑ)\sΣΥΝΝΕΦΑ|
      ΑΡΑΙΗ\sΣΥΝΝΕΦΙΑ|
      ΣΥΝΝΕΦΙΑΣΜΕΝΟΣ|
      (ΑΣΘΕΝΗΣ\s)?ΒΡΟΧΗ|
      ΚΑΤΑΙΓΙΔΑ
    }x

    def forecast
      tr_nodes = doc.css('tr.perhour')

      hour = Time.now.hour

      # Drop today's rows
      tr_nodes.shift if hour < 3
      tr_nodes.shift if hour < 9
      tr_nodes.shift if hour < 15
      tr_nodes.shift if hour < 21

      # Keep tomorrow's rows
      tr_nodes = tr_nodes.first(4)

      forecast_rows = tr_nodes.map { |tr| parse_row_text(tr) }

      HOURS.zip(forecast_rows).to_h
    end

    def sunrise
      scrape_sunrise_and_sunset! if @sunrise.nil?
      @sunrise
    end

    def sunset
      scrape_sunrise_and_sunset! if @sunset.nil?
      @sunset
    end

    private

    def doc
      @doc ||= Nokogiri::HTML::Document.parse(open(URL), nil, 'utf-8')
    end

    def parse_row_text(tr_node)
      text = tr_node.text.gsub(/^\s*|\s*$/, '').gsub(/\s+/, ' ')

      %i[temperature humidity wind conditions].map { |attr|
        [attr, send("parse_#{attr}", text)]
      }.to_h
    end

    def parse_temperature(text)
      text[/\d+°C/].to_i
    end

    def parse_humidity(text)
      text[/\d+%/].to_i
    end

    def parse_wind(text)
      text = text.tr('BAN', 'ΒΑΝ') # Latin to Greek
      matches = text.match(WIND_REGEX)

      if matches
        {
          bf: matches[:bf].to_i,
          kph: matches[:kph].to_i,
          bursts: matches[:bursts].nil? ? nil : matches[:bursts].to_i,
          direction: matches[:direction]
        }
      else
        {
          bf: 0,
          kph: 0,
          bursts: nil,
          direction: ''
        }
      end
    end

    def parse_conditions(text)
      text[CONDITIONS_REGEX]
    end

    def scrape_sunrise_and_sunset!
      nodes = doc.css('.forecastright')
      nodes.shift if Time.now.hour < 21
      @sunrise, @sunset = nodes[0].text.scan(/\d{2}:\d{2}/)
    end
  end
end
