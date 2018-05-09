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

      max_temp = weather_forecast.values.map { |f| f[:temperature] }.max

      lines = []
      lines << "Ο καιρός στην Αθήνα (κέντρο) για αύριο #{forecast_date}:"
      lines << ''
      lines.concat(
        weather_forecast.map { |hour, forecast|
          sprintf(
            '%{hr} %{he} %{t}°C%{te}, υγρασία %{h}%%, %{w}, σκόνη %{d}%{de}, %{c} %{e}',
            hr: sprintf('%02d:00', hour),
            he: hour_emoji(hour),
            t: forecast[:temperature],
            te: forecast[:temperature] == max_temp ? ' :red_circle:' : '',
            h: forecast[:humidity],
            w: forecast[:wind],
            d: dust_forecast[hour],
            de: dust_emoji(dust_forecast[hour]),
            c: forecast[:conditions],
            e: conditions_emoji(forecast[:conditions])
          )
        }
      )
      lines << ''
      lines << 'Πηγή: http://meteo.gr/cf.cfm?city_id=12'
      lines.join("\n")
    end

    def self.conditions_emoji(conditions)
      case conditions
      when 'ΚΑΘΑΡΟΣ' then ':sunny:'
      when 'ΛΙΓΑ ΣΥΝΝΕΦΑ', 'ΑΡΑΙΗ ΣΥΝΝΕΦΙΑ' then ':sun_small_cloud:'
      when 'ΑΡΚΕΤΑ ΣΥΝΝΕΦΑ' then ':sun_behind_cloud:'
      when 'ΣΥΝΝΕΦΙΑΣΜΕΝΟΣ' then ':cloud:'
      when 'ΑΣΘΕΝΗΣ ΒΡΟΧΗ', 'ΒΡΟΧΗ' then ':rain_cloud:'
      when 'ΚΑΤΑΙΓΙΔΑ' then ':thunder_cloud_and_rain:'
      end
    end

    def self.dust_emoji(level)
      return ' :warning:' if %w[ΥΨΗΛΗ ΜΕΣΑΙΑ].include?(level)
    end

    def self.hour_emoji(hour)
      ":clock#{hour % 12}:"
    end

    def self.forecast_date
      tomorrow = Date.today + 1
      day = DAYS[tomorrow.cwday - 1]
      "#{day} #{tomorrow.day}/#{tomorrow.month}"
    end
  end
end
