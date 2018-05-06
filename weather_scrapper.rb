require 'nokogiri'
require 'open-uri'

module SlackWeather
  class WeatherScrapper
    HOURS = [3, 9, 15, 21].freeze
    URL = 'http://meteo.gr/cf.cfm?city_id=12'.freeze

    def self.forecast
      doc = Nokogiri::HTML::Document.parse(open(URL), nil, 'utf-8')

      tr_nodes = doc.css('tr.perhour')

      hour = Time.now.hour

      # Drop today's rows
      tr_nodes.shift if hour < 3
      tr_nodes.shift if hour < 9
      tr_nodes.shift if hour < 15
      tr_nodes.shift if hour < 21

      # Keep tomorrow's rows
      tr_nodes = tr_nodes.first(4)

      forecast_rows =
        tr_nodes.map do |tr_node|
          values = tr_node.text.gsub(/^\s*|\s*$/, '').split("\n").uniq
          {
            temperature: values[1].to_i,
            humidity: values[2].to_i,
            wind: values[3],
            conditions: values[5]
          }
        end

      HOURS.zip(forecast_rows).to_h
    end
  end
end
