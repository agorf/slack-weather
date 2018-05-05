require_relative 'dust_scrapper'
require_relative 'weather_scrapper'
require 'date'

module SlackWeather
  class MessageComposer
    DAYS = %w[
      Δευτέρα
      Τρίτη
      Τετάρτη
      Πέμπτη
      Παρασκευή
      Σάββατο
      Κυριακή
    ].freeze

    def self.message
      dust_forecast = DustScrapper.forecast
      weather_forecast = WeatherScrapper.forecast

      tomorrow = Date.today + 1
      day = DAYS[tomorrow.cwday - 1]

      lines = []
      lines << "Ο καιρός για αύριο #{day} #{tomorrow.day}/#{tomorrow.month}:"
      lines << ''
      lines.concat(
        weather_forecast.map { |hour, forecast|
          '*%{hr}* %{t}°C, υγρασία %{h}%%, %{w}, σκόνη %{d}, %{c}' % {
            hr: '%02d:00' % hour,
            t: forecast[:temperature],
            h: forecast[:humidity],
            w: forecast[:wind],
            d: dust_forecast[hour],
            c: forecast[:conditions]
          }
        }
      )
      lines << ''
      lines << 'Πηγή: http://meteo.gr/cf.cfm?city_id=12'
      lines.join("\n")
    end
  end
end
