require_relative 'dust_scraper'
require_relative 'weather_scraper'
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
      dust_forecast = DustScraper.forecast
      weather = WeatherScraper.new
      weather_forecast = weather.forecast

      max_temp = weather_forecast.values.map { |f| f[:temperature] }.max

      lines = []
      lines << "Ο καιρός στην Αθήνα (κέντρο) για αύριο #{forecast_date}:"
      lines << ''
      lines.concat(
        weather_forecast.map { |hour, forecast|
          temp = "#{forecast[:temperature]}°C"
          temp = "*#{temp}*" if forecast[:temperature] == max_temp

          if forecast[:wind][:bf] == 0
            wind = 'ΑΠΝΟΙΑ'
          else
            wind = "#{forecast[:wind][:bf]} Bf"

            if forecast[:wind][:bf] >= 6
              wind = "*#{wind}*"
            end

            wind << " #{wind_emoji(forecast[:wind][:direction])}"
            wind << " #{forecast[:wind][:direction]}"
            wind << " (#{forecast[:wind][:kph]} km/h"

            if forecast[:wind][:bursts]
              wind << ", ριπές #{forecast[:wind][:bursts]} km/h"
            end

            wind << ')'
          end

          dust = dust_forecast[hour]
          dust = "*#{dust}*" if %w[ΥΨΗΛΗ ΜΕΣΑΙΑ].include?(dust)

          [
            [
              sprintf('%02d:00', hour),
              hour_emoji(hour),
              temp
            ].join(' '),
            [
              'υγρασία',
              "#{forecast[:humidity]}%"
            ].join(' '),
            wind,
            [
              'σκόνη',
              dust
            ].join(' '),
            [
              'συνθήκες',
              forecast[:conditions],
              conditions_emoji(forecast[:conditions])
            ].join(' ')
          ].join(', ')
        }
      )
      lines << ''
      lines << "Ανατολή: :city_sunrise: #{weather.sunrise} - " \
        "Δύση: :city_sunset: #{weather.sunset}"
      lines << ''
      lines << 'Πηγή: http://meteo.gr/cf.cfm?city_id=12'
      lines.join("\n")
    end

    def self.conditions_emoji(conditions)
      case conditions
      when 'ΚΑΘΑΡΟΣ' then ':sunny:'
      when 'ΠΕΡΙΟΡΙΣΜΕΝΗ ΟΡΑΤΟΤΗΤΑ' then ':fog:'
      when 'ΛΙΓΑ ΣΥΝΝΕΦΑ' then ':sun_small_cloud:'
      when 'ΑΡΑΙΗ ΣΥΝΝΕΦΙΑ', 'ΑΡΚΕΤΑ ΣΥΝΝΕΦΑ' then ':sun_behind_cloud:'
      when 'ΣΥΝΝΕΦΙΑΣΜΕΝΟΣ' then ':cloud:'
      when 'ΑΣΘΕΝΗΣ ΒΡΟΧΗ', 'ΒΡΟΧΗ' then ':rain_cloud:'
      when 'ΚΑΤΑΙΓΙΔΑ' then ':thunder_cloud_and_rain:'
      end
    end

    def self.hour_emoji(hour)
      ":clock#{hour % 12}:"
    end

    def self.wind_emoji(direction)
      case direction
      when 'Β' then ':arrow_down:'
      when 'ΒΑ' then ':arrow_lower_left:'
      when 'Α' then ':arrow_left:'
      when 'ΝΑ' then ':arrow_upper_left:'
      when 'Ν' then ':arrow_up:'
      when 'ΝΔ' then ':arrow_upper_right:'
      when 'Δ' then ':arrow_right:'
      when 'ΒΔ' then ':arrow_lower_right:'
      end
    end

    def self.forecast_date
      tomorrow = Date.today + 1
      day = DAYS[tomorrow.cwday - 1]
      "#{day} #{tomorrow.day}/#{tomorrow.month}"
    end
  end
end
