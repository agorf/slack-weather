require 'nokogiri'
require 'open-uri'

module SlackWeather
  class DustScraper
    HOURS = [3, 9, 15, 21].freeze
    URL = 'http://meteo.gr/includes/dust-include.cfm?city_id=12'.freeze

    def self.forecast
      doc = Nokogiri::HTML::Document.parse(open(URL), nil, 'utf-8')

      td_nodes = doc.css('td').select { |td| td.text =~ /ΣΚΟΝΗ/ }

      hour = Time.now.hour

      # Drop today's rows
      td_nodes.shift if hour < 3
      td_nodes.shift if hour < 9
      td_nodes.shift if hour < 15
      td_nodes.shift if hour < 21

      # Keep only tomorrow's rows
      td_nodes = td_nodes.first(4)

      levels =
        td_nodes.map do |td|
          level = td.text.split(' ').first
          case level
          when 'ΥΨΗΛΗ', 'ΜΕΣΑΙΑ', 'ΧΑΜΗΛΗ' then level
          when 'ΔΕΝ' then 'ΚΑΘΟΛΟΥ'
          end
        end

      HOURS.zip(levels).to_h
    end
  end
end
